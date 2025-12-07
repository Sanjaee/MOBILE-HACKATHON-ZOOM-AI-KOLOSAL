import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/text_styles.dart';
import '../../../routes/app_routes.dart';
import '../widgets/chatbot.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: const Text(
          'Zacode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 18,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated gradient background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0A0A0F),
                ),
                child: Stack(
                  children: [
                    // Primary gradient orb - matches Next.js opacity-30 blur-[120px]
                    Positioned(
                      left: -200,
                      top: -200,
                      child: Container(
                        width: 800,
                        height: 800,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6366F1).withValues(alpha: 0.3),
                              const Color(0xFF6366F1).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                    // Secondary gradient orb - matches Next.js opacity-25 blur-[100px]
                    Positioned(
                      right: -100,
                      bottom: -100,
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFEC4899).withValues(alpha: 0.25),
                              const Color(0xFFEC4899).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                    // Tertiary gradient orb - matches Next.js opacity-20 blur-[80px]
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 250,
                      top: MediaQuery.of(context).size.height / 2 - 250,
                      child: Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF06B6D4).withValues(alpha: 0.2),
                              const Color(0xFF06B6D4).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                    ),
                    // Grid overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const SizedBox(height: 40),
                    // Main heading with gradient
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildGradientText(
                            'Zoom Meeting',
                            fontSize: 36,
                            gradient: const [
                              Color(0xFFFFFFFF),
                              Color(0xFFE5E7EB),
                              Color(0xFF9CA3AF),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildGradientText(
                            'AI Agent',
                            fontSize: 36,
                            gradient: const [
                              Color(0xFF818CF8),
                              Color(0xFFA78BFA),
                              Color(0xFFF472B6),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Platform meeting profesional dengan AI Agent untuk UMKM. '
                        'Transkrip, analisis, dan rekomendasi otomatis dari setiap pertemuan dengan investor.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Enter Platform Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildEnterButton(context, isDark),
                    ),
                    const SizedBox(height: 40),
                    
                    // Features Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          _buildFeatureCard(
                            context: context,
                            isDark: isDark,
                            title: 'AI Agent Cerdas',
                            subtitle: 'Transkrip & analisis otomatis',
                            icon: Icons.auto_awesome,
                            gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            onTap: () => Navigator.pushNamed(context, AppRoutes.rooms),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            context: context,
                            isDark: isDark,
                            title: 'Meeting Profesional',
                            subtitle: 'Kualitas HD untuk investor',
                            icon: Icons.videocam,
                            gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
                            onTap: () => Navigator.pushNamed(context, AppRoutes.rooms),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            context: context,
                            isDark: isDark,
                            title: 'Aman & Terpercaya',
                            subtitle: 'Data meeting terlindungi',
                            icon: Icons.security,
                            gradient: const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
                            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Platform Meeting UMKM dengan AI Agent · LiveKit · Kolosal AI',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
          ],
        ),
      ),
        ),
        // Chatbot Widget - Floating button
        const Chatbot(),
      ],
    );
  }
  
  Widget _buildGradientText(String text, {required double fontSize, required List<Color> gradient}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradient,
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildEnterButton(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.rooms),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter Platform',
                  style: AppTextStyles.button(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Grid painter for background - matches Next.js opacity-[0.03]
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const gridSize = 100.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

