import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/services/chat_service.dart';
import '../../../core/constants/text_styles.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isOpen = false;
  bool _isLoading = false;
  bool _isAIActive = false;
  bool _isAIMessage = false; // Detects if message starts with @ai or @agen
  String? _currentRoomId; // Will be set when needed
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_checkAIMessage);
  }

  @override
  void dispose() {
    _inputController.removeListener(_checkAIMessage);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkAIMessage() {
    final text = _inputController.text.trim().toLowerCase();
    // Check if starts with @ai or @agen (with or without space)
    final isAI = text.startsWith('@ai') || text.startsWith('@agen');
    if (_isAIMessage != isAI) {
      setState(() {
        _isAIMessage = isAI;
      });
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

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Check if it's an AI request
    final isAIRequest = text.toLowerCase().startsWith('@ai ') || text.toLowerCase().startsWith('@agen ');
    final messageToShow = text; // Keep original message for display
    final aiPrompt = isAIRequest 
        ? text.replaceFirst(RegExp(r'^@(ai|agen)\s+', caseSensitive: false), '').trim()
        : text;

    // Add user message
    setState(() {
      _messages.add({
        'role': 'user',
        'content': messageToShow,
        'timestamp': DateTime.now(),
      });
      _inputController.clear();
      _isLoading = true;
      _isAIActive = true;
      _isAIMessage = false;
    });
    _scrollToBottom();

    try {
      // For now, use a default room ID or get from context
      // In production, you might want to get this from navigation or context
      final roomId = _currentRoomId ?? 'default-room';
      
      if (isAIRequest && aiPrompt.isNotEmpty) {
      // Call AI API (without agent mode since we don't have valid workspace_id)
      // Backend will use regular chat mode
      final response = await _chatService.callKolosalAgent(
        roomId: roomId,
        prompt: aiPrompt,
        useAgent: false, // Don't use agent mode without valid workspace_id
      );

        // Extract response
        final aiResponse = response['response'] ?? response['message']?['message'] ?? 'No response from AI';
        
        // Add AI response
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': aiResponse,
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
          _isAIActive = false;
        });
      } else if (isAIRequest && aiPrompt.isEmpty) {
        // AI request but no prompt
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Pertanyaan AI tidak boleh kosong. Silakan ketik pertanyaan setelah @ai atau @agen.',
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
          _isAIActive = false;
        });
      } else {
        // Regular message (not AI) - just show echo for now
        // In production, you might want to send to regular chat
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Untuk menggunakan AI, ketik @ai atau @agen di awal pesan.',
            'timestamp': DateTime.now(),
          });
          _isLoading = false;
          _isAIActive = false;
        });
      }
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Maaf, terjadi kesalahan. Silakan coba lagi.',
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
        _isAIActive = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Floating Button
        Positioned(
          bottom: 24,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: (_isAIActive || _isAIMessage)
                  ? const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: ((_isAIActive || _isAIMessage) ? const Color(0xFF10B981) : const Color(0xFF8B5CF6))
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isOpen = !_isOpen),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Chat Dialog
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping dialog
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      constraints: BoxConstraints(
                        maxWidth: 500,
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.message,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AI Agent',
                                      style: AppTextStyles.h4(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _isOpen = false),
                                    ),
                                  ],
                                ),
                              ),

                              // Messages
                              Flexible(
                                child: _messages.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Belum ada pesan',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Mulai percakapan sekarang!',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(16),
                                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (index == _messages.length && _isLoading) {
                                            return _buildLoadingIndicator();
                                          }
                                          return _buildMessage(_messages[index]);
                                        },
                                      ),
                              ),

                              // Input
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _inputController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Ketik pesan...',
                                          hintStyle: TextStyle(color: Colors.grey[400]),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(24),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(alpha: 0.2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(24),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF818CF8),
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.1),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        onSubmitted: (_) => _sendMessage(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: (_isAIMessage || _isAIActive)
                                            ? const LinearGradient(
                                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                              )
                                            : const LinearGradient(
                                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                              ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _sendMessage,
                                          borderRadius: BorderRadius.circular(24),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: const Icon(
                                              Icons.send,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tip text
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  'Tip: Gunakan @ai atau @agen di awal pesan untuk bertanya ke AI. Upload gambar untuk OCR.',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF6366F1)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message['content'] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

