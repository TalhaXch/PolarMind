import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/controllers/controllers.dart';
import '../theme/app_theme.dart';
import '../widgets/game_board.dart';
import 'level_complete_screen.dart';

/// Main game screen where levels are played.
class GameScreen extends StatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  LevelController? _levelController;
  late AnimationController _tickController;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _initializeLevel();

    // Set up game tick
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _tickController.addListener(_onTick);
  }

  void _initializeLevel() {
    final gameState = Provider.of<GameStateController>(context, listen: false);
    final level = gameState.getLevel(widget.levelId);

    if (level != null) {
      _levelController = LevelController(level);
      _levelController!.addListener(_onLevelStateChanged);
    }
  }

  DateTime _lastTick = DateTime.now();

  void _onTick() {
    if (_levelController == null) return;

    final now = DateTime.now();
    final deltaTime = (now.difference(_lastTick).inMicroseconds) / 1000000.0;
    _lastTick = now;

    _levelController!.update(deltaTime);
  }

  void _onLevelStateChanged() {
    if (_levelController != null && _levelController!.isCompleted) {
      _onLevelCompleted();
    }
    if (mounted) setState(() {});
  }

  void _onLevelCompleted() {
    // Save progress
    final gameState = Provider.of<GameStateController>(context, listen: false);
    gameState.completeLevel(
      widget.levelId,
      toggleCount: _levelController!.toggleCount,
      time: _levelController!.state.completionTime,
    );

    // Navigate to completion screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => LevelCompleteScreen(
                  levelId: widget.levelId,
                  toggleCount: _levelController!.toggleCount,
                  completionTime:
                      _levelController!.state.completionTime ?? Duration.zero,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _tickController.removeListener(_onTick);
    _tickController.dispose();
    _levelController?.removeListener(_onLevelStateChanged);
    _levelController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_levelController == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(
            child: Text(
              'Level not found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(),
              // Game info
              _buildGameInfo(),
              // Game board
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GameBoard(controller: _levelController!),
                ),
              ),
              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.highlight,
            onPressed: () => _showExitConfirmation(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level ${widget.levelId}', style: AppTheme.headingSmall),
                Text(_levelController!.level.name, style: AppTheme.bodySmall),
              ],
            ),
          ),
          // Hint button
          if (_levelController!.hint != null)
            IconButton(
              icon: Icon(
                Icons.lightbulb_outline_rounded,
                color: _showHint ? AppTheme.warning : AppTheme.accent,
              ),
              onPressed: () => setState(() => _showHint = !_showHint),
            ),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(
                icon: Icons.touch_app_rounded,
                label: 'Toggles',
                value:
                    _levelController!.hasToggleLimit
                        ? '${_levelController!.toggleCount}/${_levelController!.level.maxToggleCount}'
                        : '${_levelController!.toggleCount}',
                warning:
                    _levelController!.hasToggleLimit &&
                    _levelController!.remainingToggles <= 1,
              ),
              _buildInfoChip(
                icon: Icons.flag_rounded,
                label: 'Status',
                value:
                    _levelController!.isCompleted ? 'Complete!' : 'In Progress',
                success: _levelController!.isCompleted,
              ),
            ],
          ),
          // Hint display
          if (_showHint && _levelController!.hint != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: AppTheme.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _levelController!.hint!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    bool warning = false,
    bool success = false,
  }) {
    Color color = AppTheme.accent;
    if (warning) color = AppTheme.warning;
    if (success) color = AppTheme.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTheme.bodySmall.copyWith(fontSize: 10)),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Restart button
          _buildControlButton(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            onTap: _levelController!.restart,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryMedium.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(label, style: AppTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.primaryMedium,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Leave Level?', style: AppTheme.headingSmall),
            content: Text(
              'Your progress on this level will be lost.',
              style: AppTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Stay', style: AppTheme.bodyMedium),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Leave'),
              ),
            ],
          ),
    );
  }
}
