import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: CustomAppBar(
        title: 'BeRealTime',
        leading: const SizedBox.shrink(),
        onProfileTap: () {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
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
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.grey[900],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

