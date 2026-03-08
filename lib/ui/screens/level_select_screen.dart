import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/controllers/controllers.dart';
import '../../game/models/models.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

/// Level selection screen organized by difficulty.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<DifficultyTier> _tiers = DifficultyTier.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tiers.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateController>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.highlight,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('SELECT LEVEL', style: AppTheme.headingMedium),
                  ],
                ),
              ),
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTheme.bodyMedium,
                  labelColor: AppTheme.highlight,
                  unselectedLabelColor: AppTheme.accent,
                  tabs:
                      _tiers
                          .map((tier) => Tab(text: _getTierShortName(tier)))
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Level grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children:
                      _tiers
                          .map(
                            (tier) => _buildLevelGrid(
                              context,
                              gameState.getLevelsByDifficulty(tier),
                              gameState,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTierShortName(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.beginner:
        return 'Easy';
      case DifficultyTier.intermediate:
        return 'Medium';
      case DifficultyTier.advanced:
        return 'Hard';
      case DifficultyTier.expert:
        return 'Expert';
    }
  }

  Widget _buildLevelGrid(
    BuildContext context,
    List<Level> levels,
    GameStateController gameState,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = gameState.isLevelUnlocked(level.id);
        final isCompleted = gameState.isLevelCompleted(level.id);

        return _LevelTile(
          levelNumber: level.id,
          isUnlocked: isUnlocked,
          isCompleted: isCompleted,
          onTap: isUnlocked ? () => _navigateToGame(context, level) : null,
        );
      },
    );
  }

  void _navigateToGame(BuildContext context, Level level) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                GameScreen(levelId: level.id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBorderColor(), width: 1.5),
            boxShadow:
                isCompleted
                    ? [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                    : null,
          ),
          child: Stack(
            children: [
              // Level number
              Center(
                child: Text(
                  isUnlocked ? '$levelNumber' : '',
                  style: AppTheme.headingSmall.copyWith(
                    color:
                        isUnlocked
                            ? AppTheme.highlight
                            : AppTheme.accent.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // Lock icon
              if (!isUnlocked)
                Center(
                  child: Icon(
                    Icons.lock_rounded,
                    color: AppTheme.accent.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ),
              // Completion indicator
              if (isCompleted)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isCompleted) {
      return AppTheme.primaryLight.withValues(alpha: 0.4);
    }
    if (isUnlocked) {
      return AppTheme.primaryMedium;
    }
    return AppTheme.primaryDark.withValues(alpha: 0.5);
  }

  Color _getBorderColor() {
    if (isCompleted) {
      return AppTheme.success;
    }
    if (isUnlocked) {
      return AppTheme.accent.withValues(alpha: 0.5);
    }
    return AppTheme.accent.withValues(alpha: 0.2);
  }
}
