import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/controllers/controllers.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

/// Level completion screen with stats and navigation options.
class LevelCompleteScreen extends StatefulWidget {
  final int levelId;
  final int toggleCount;
  final Duration completionTime;

  const LevelCompleteScreen({
    super.key,
    required this.levelId,
    required this.toggleCount,
    required this.completionTime,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateController>(context);
    final nextLevelId = gameState.getNextLevelId(widget.levelId);
    final hasNextLevel =
        nextLevelId != null && gameState.isLevelUnlocked(nextLevelId);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Animated success indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildSuccessIcon(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'LEVEL COMPLETE!',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.success,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Level ${widget.levelId}',
                    style: AppTheme.headingSmall,
                  ),
                ),
                const Spacer(flex: 1),
                // Stats
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStatsCard(),
                ),
                const Spacer(flex: 2),
                // Buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      if (hasNextLevel)
                        _buildButton(
                          context,
                          label: 'NEXT LEVEL',
                          icon: Icons.arrow_forward_rounded,
                          onTap:
                              () => _navigateToNextLevel(context, nextLevelId),
                          isPrimary: true,
                        ),
                      if (hasNextLevel) const SizedBox(height: 12),
                      _buildButton(
                        context,
                        label: 'REPLAY',
                        icon: Icons.replay_rounded,
                        onTap: () => _replayLevel(context),
                      ),
                      const SizedBox(height: 12),
                      _buildButton(
                        context,
                        label: 'LEVEL SELECT',
                        icon: Icons.grid_view_rounded,
                        onTap: () => _navigateToLevelSelect(context),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [AppTheme.success.withValues(alpha: 0.3), Colors.transparent],
        ),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.success,
            boxShadow: AppTheme.magnetGlow(AppTheme.success),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final timeFormatted = _formatDuration(widget.completionTime);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Text('YOUR STATS', style: AppTheme.bodyLarge),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.touch_app_rounded,
                value: '${widget.toggleCount}',
                label: 'Toggles',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.accent.withValues(alpha: 0.3),
              ),
              _buildStatItem(
                icon: Icons.timer_rounded,
                value: timeFormatted,
                label: 'Time',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accent, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.headingMedium),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  Widget _buildButton(
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
                      ? const LinearGradient(
                        colors: [AppTheme.success, Color(0xFF1B7A4A)],
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
                        ? AppTheme.success
                        : AppTheme.accent.withValues(alpha: 0.3),
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

  void _navigateToNextLevel(BuildContext context, int nextLevelId) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                GameScreen(levelId: nextLevelId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _replayLevel(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                GameScreen(levelId: widget.levelId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToLevelSelect(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const LevelSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
