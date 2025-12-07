import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/services/chat_service.dart';
import '../../../core/constants/app_colors.dart';

class ChatSidebar extends StatefulWidget {
  final String roomId;
  final VoidCallback? onClose;

  const ChatSidebar({
    super.key,
    required this.roomId,
    this.onClose,
  });

  @override
  State<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isAIStreaming = false;
  String? _streamingUserId;
  String? _currentUserId;
  StreamSubscription<ChatMessageModel>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _aiMessageSubscription;
  
  // Store streaming AI messages temporarily
  Map<String, ChatMessageModel> _streamingAIMessages = {};

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _aiMessageSubscription?.cancel();
    _chatService.disconnectWebSocket();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      // Get current user ID from token
      _currentUserId = await _chatService.getCurrentUserId();
      debugPrint('[ChatSidebar] Current user ID: $_currentUserId');

      // Load existing messages
      final messages = await _chatService.getMessages(widget.roomId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }

      // Connect to WebSocket for real-time updates
      final stream = await _chatService.connectWebSocket(widget.roomId);
      _messageSubscription = stream.listen((message) {
        if (mounted) {
          setState(() {
            // Avoid duplicates
            final exists = _messages.any((m) => m.id == message.id);
            if (!exists) {
              _messages.add(message);
            }
          });
          _scrollToBottom();
        }
      });

      // Listen for AI messages (typing, streaming, complete)
      final aiStream = _chatService.aiMessageStream;
      if (aiStream != null) {
        _aiMessageSubscription = aiStream.listen((aiMessage) {
          if (!mounted) return;
          
          final type = aiMessage['type'] as String?;
          final payload = aiMessage['payload'] as Map<String, dynamic>?;
          
          if (type == 'ai_typing' && payload != null) {
            setState(() {
              _isAIStreaming = true;
              _streamingUserId = payload['user_id'] as String?;
            });
            debugPrint('[ChatSidebar] AI typing started by: ${_streamingUserId}');
          } else if (type == 'ai_stream' && payload != null) {
            setState(() {
              _isAIStreaming = true;
              _streamingUserId = payload['user_id'] as String?;
            });
            
            final tempId = payload['id'] as String? ?? 'ai-temp-${DateTime.now().millisecondsSinceEpoch}';
            final content = payload['content'] as String? ?? '';
            final userId = payload['user_id'] as String? ?? 'ai-agent';
            final userName = payload['user_name'] as String? ?? 'AI Agent';
            final userEmail = payload['user_email'] as String? ?? 'ai@agent.com';
            
            // Update or create streaming message
            final streamingMessage = ChatMessageModel(
              id: tempId,
              roomId: widget.roomId,
              userId: userId,
              userName: userName,
              userEmail: userEmail,
              message: content,
              createdAt: DateTime.now(),
            );
            
            setState(() {
              _streamingAIMessages[tempId] = streamingMessage;
              
              // Remove old streaming message and add new one
              _messages.removeWhere((m) => m.id == tempId);
              _messages.add(streamingMessage);
            });
            _scrollToBottom();
          } else if (type == 'ai_complete' && payload != null) {
            setState(() {
              _isAIStreaming = false;
              _streamingUserId = null;
            });
            
            final tempId = payload['temp_id'] as String?;
            final finalMessageData = payload['message'] as Map<String, dynamic>?;
            
            if (tempId != null) {
              // Remove streaming message
              _messages.removeWhere((m) => m.id == tempId);
              _streamingAIMessages.remove(tempId);
            }
            
            if (finalMessageData != null) {
              // Add final message
              final finalMessage = ChatMessageModel.fromJson(finalMessageData);
              final exists = _messages.any((m) => m.id == finalMessage.id);
              if (!exists) {
                setState(() {
                  _messages.add(finalMessage);
                });
                _scrollToBottom();
              }
            }
          } else if (type == 'ai_error' && payload != null) {
            setState(() {
              _isAIStreaming = false;
              _streamingUserId = null;
            });
            
            final errorMsg = payload['error'] as String? ?? 'Terjadi kesalahan pada AI';
            _showError(errorMsg);
          }
        });
      }
    } catch (e) {
      debugPrint('[ChatSidebar] Error initializing chat: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Gagal memuat chat: $e');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _isAIStreaming) return;

    // Check if it's an AI request
    final isAIRequest = text.toLowerCase().startsWith('@ai ') || text.toLowerCase().startsWith('@agen ');
    final aiPrompt = isAIRequest 
        ? text.replaceFirst(RegExp(r'^@(ai|agen)\s+', caseSensitive: false), '').trim()
        : null;

    if (isAIRequest && aiPrompt != null && aiPrompt.isNotEmpty) {
      // Handle AI request
      setState(() {
        _isSending = true;
      });

      try {
        // Call Kolosal API (without agent mode since we don't have valid workspace_id)
        // Backend will use regular chat mode
        await _chatService.callKolosalAgent(
          roomId: widget.roomId,
          prompt: aiPrompt,
          useAgent: false, // Don't use agent mode without valid workspace_id
        );
        
        // Clear input - WebSocket will handle the rest
        _messageController.clear();
        
        // Add user message to chat
        final userMessage = ChatMessageModel(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          roomId: widget.roomId,
          userId: _currentUserId ?? 'unknown',
          userName: 'You',
          userEmail: '',
          message: text,
          createdAt: DateTime.now(),
        );
        
        if (mounted) {
          setState(() {
            _messages.add(userMessage);
          });
          _scrollToBottom();
        }
      } catch (e) {
        debugPrint('[ChatSidebar] Error calling AI: $e');
        _showError('Gagal memanggil AI: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    } else if (isAIRequest && (aiPrompt == null || aiPrompt.isEmpty)) {
      // AI request but no prompt
      _showError('Pertanyaan AI tidak boleh kosong. Silakan ketik pertanyaan setelah @ai atau @agen.');
    } else {
      // Regular message
      setState(() {
        _isSending = true;
      });

      try {
        final message = await _chatService.sendMessage(widget.roomId, text);
        _messageController.clear();
        
        // Add message if not already received via WebSocket
        if (mounted) {
          setState(() {
            final exists = _messages.any((m) => m.id == message.id);
            if (!exists) {
              _messages.add(message);
            }
          });
          _scrollToBottom();
        }
      } catch (e) {
        debugPrint('[ChatSidebar] Error sending message: $e');
        _showError('Gagal mengirim pesan');
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937), // gray-800
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Messages
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
          ),
          
          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111827), // gray-900
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (widget.onClose != null)
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesan',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai percakapan sekarang!',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isOwnMessage = _currentUserId != null && 
            _currentUserId == message.userId;
        
        return _buildMessageBubble(message, isOwnMessage);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isOwnMessage) {
    final isAI = message.userId == 'ai-agent' || message.userEmail == 'ai@agent.com' || message.userName == 'AI Agent';
    final isStreaming = _streamingAIMessages.containsKey(message.id);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isOwnMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage) ...[
            // Avatar for other users / AI
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isAI
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : null,
                color: isAI ? null : const Color(0xFF4B5563), // gray-600
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: isAI
                    ? const Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: 18,
                      )
                    : Text(
                        message.userName.isNotEmpty 
                            ? message.userName[0].toUpperCase() 
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isOwnMessage 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                // Sender name (for others)
                if (!isOwnMessage)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          message.userName,
                          style: TextStyle(
                            color: isAI ? const Color(0xFF10B981) : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: isAI ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isStreaming) ...[
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                
                // Message bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOwnMessage 
                        ? const Color(0xFF2563EB) // blue-600
                        : isAI
                            ? const Color(0xFF10B981).withValues(alpha: 0.2) // green with opacity
                            : const Color(0xFF374151), // gray-700
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
                      bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
                    ),
                    border: isAI && !isOwnMessage
                        ? Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                
                // Time
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isOwnMessage) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111827), // gray-900
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              12, 
              12, 
              12, 
              12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151), // gray-700
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      enabled: !_isAIStreaming,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _isAIStreaming 
                            ? 'AI sedang memproses...'
                            : 'Ketik @ai',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (_isSending || _isAIStreaming) ? null : _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (_isSending || _isAIStreaming)
                          ? Colors.grey[700] 
                          : const Color(0xFF2563EB), // blue-600
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: (_isSending || _isAIStreaming)
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Tip text
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              8 + MediaQuery.of(context).viewPadding.bottom,
            ),
            child: Text(
              'Tip: Gunakan @ai atau @agen di awal pesan untuk bertanya ke AI. Upload gambar untuk OCR.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

