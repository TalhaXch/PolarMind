import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/controllers/controllers.dart';
import '../theme/app_theme.dart';
import 'level_select_screen.dart';

/// Home screen with main menu.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateController>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Logo
                _buildLogo(),
                const SizedBox(height: 16),
                // Title
                Text('POLARMIND', style: AppTheme.headingLarge),
                const SizedBox(height: 8),
                Text(
                  'Magnetic Puzzle Logic',
                  style: AppTheme.bodyMedium.copyWith(letterSpacing: 1.5),
                ),
                const Spacer(flex: 2),
                // Progress indicator
                if (gameState.totalLevels > 0) ...[
                  _buildProgressCard(gameState),
                  const SizedBox(height: 32),
                ],
                // Menu buttons
                _buildMenuButton(
                  context,
                  label: 'PLAY',
                  icon: Icons.play_arrow_rounded,
                  onTap: () => _navigateToLevelSelect(context),
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  label: 'LEVEL SELECT',
                  icon: Icons.grid_view_rounded,
                  onTap: () => _navigateToLevelSelect(context),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  label: 'HOW TO PLAY',
                  icon: Icons.help_outline_rounded,
                  onTap: () => _showHowToPlay(context),
                ),
                const Spacer(flex: 2),
                // Settings row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        gameState.isSoundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: AppTheme.accent,
                      ),
                      onPressed: gameState.toggleSound,
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: Icon(
                        gameState.isMusicEnabled
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        color: AppTheme.accent,
                      ),
                      onPressed: gameState.toggleMusic,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'v1.0.0',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.highlight.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // North pole
          Positioned(top: 12, child: _buildPole('+', AppTheme.northPole)),
          // South pole
          Positioned(bottom: 12, child: _buildPole('−', AppTheme.southPole)),
          // Center line
          Container(
            width: 2,
            height: 35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.northPole,
                  AppTheme.highlight,
                  AppTheme.southPole,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPole(String symbol, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: AppTheme.magnetGlow(color),
      ),
      child: Center(
        child: Text(
          symbol,
          style: AppTheme.polaritySymbol.copyWith(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildProgressCard(GameStateController gameState) {
    final percentage = (gameState.completionPercentage * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTheme.bodyLarge),
              Text(
                '${gameState.completedLevels}/${gameState.totalLevels}',
                style: AppTheme.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: gameState.completionPercentage,
              backgroundColor: AppTheme.primaryDark,
              valueColor: AlwaysStoppedAnimation(
                percentage == 100 ? AppTheme.success : AppTheme.accent,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient:
                  isPrimary
                      ? LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primaryMedium],
                      )
                      : null,
              color:
                  isPrimary
                      ? null
                      : AppTheme.primaryMedium.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isPrimary
                        ? AppTheme.accent
                        : AppTheme.accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.highlight, size: 24),
                const SizedBox(width: 12),
                Text(label, style: AppTheme.buttonText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLevelSelect(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const LevelSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.primaryMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('How to Play', style: AppTheme.headingMedium),
                const SizedBox(height: 16),
                _buildHelpItem(
                  Icons.touch_app,
                  'Tap magnets to toggle polarity',
                  '+ (North) and − (South)',
                ),
                _buildHelpItem(
                  Icons.trending_flat,
                  'Opposite poles attract',
                  '+ attracts −',
                ),
                _buildHelpItem(
                  Icons.unfold_more,
                  'Like poles repel',
                  '+ repels +, − repels −',
                ),
                _buildHelpItem(
                  Icons.flag,
                  'Guide the ball to the goal',
                  'Use magnetic forces strategically',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyLarge),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
