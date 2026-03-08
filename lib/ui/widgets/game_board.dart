import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/config/game_config.dart';
import '../../core/physics/magnet_force_calculator.dart';
import '../../game/controllers/level_controller.dart';
import '../../game/models/models.dart';
import '../theme/app_theme.dart';

/// Main game board widget that renders the level and handles interactions.
class GameBoard extends StatelessWidget {
  final LevelController controller;

  const GameBoard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate scale to fit the level in available space
            final levelWidth = controller.level.pixelWidth;
            final levelHeight = controller.level.pixelHeight;

            final scaleX = constraints.maxWidth / levelWidth;
            final scaleY = constraints.maxHeight / levelHeight;
            final scale = math.min(scaleX, scaleY);

            final scaledWidth = levelWidth * scale;
            final scaledHeight = levelHeight * scale;

            return Center(
              child: Container(
                width: scaledWidth,
                height: scaledHeight,
                decoration: BoxDecoration(
                  gradient: AppTheme.gameAreaGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GestureDetector(
                    onTapDown:
                        (details) => _handleTap(details.localPosition, scale),
                    child: Stack(
                      children: [
                        // Grid lines (subtle)
                        _buildGrid(scaledWidth, scaledHeight, scale),
                        // Goal zone (rendered first, behind objects)
                        _buildGoalZone(scale),
                        // Obstacles
                        ..._buildObstacles(scale),
                        // Force lines (visual feedback)
                        CustomPaint(
                          size: Size(scaledWidth, scaledHeight),
                          painter: _ForceLinesPainter(
                            magneticObjects: controller.magneticObjects,
                            fixedMagnets: controller.fixedMagnets,
                            scale: scale,
                          ),
                        ),
                        // Fixed magnets
                        ..._buildFixedMagnets(scale),
                        // Magnetic objects
                        ..._buildMagneticObjects(scale),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Handle tap events - prioritize magnets over objects
  void _handleTap(Offset position, double scale) {
    // Convert tap position to game coordinates
    final gameX = position.dx / scale;
    final gameY = position.dy / scale;

    // First, check if any toggleable magnet was tapped (priority)
    for (final magnet in controller.fixedMagnets) {
      if (!magnet.canToggle || !controller.canToggle) continue;

      final dx = gameX - magnet.position.x;
      final dy = gameY - magnet.position.y;
      final distance = math.sqrt(dx * dx + dy * dy);

      // Use slightly larger hit area for better usability
      if (distance <= GameConfig.magnetRadius * 1.5) {
        controller.toggleMagnet(magnet.id);
        return;
      }
    }
  }

  Widget _buildGrid(double width, double height, double scale) {
    return CustomPaint(
      size: Size(width, height),
      painter: _GridPainter(
        gridSize: GameConfig.gridSize * scale,
        color: AppTheme.accent.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildGoalZone(double scale) {
    final goal = controller.goalZone;
    final radius = goal.radius * scale;

    return Positioned(
      left: goal.position.x * scale - radius,
      top: goal.position.y * scale - radius,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              goal.isReached
                  ? AppTheme.success.withValues(alpha: 0.3)
                  : AppTheme.goalColor.withValues(alpha: 0.2),
          border: Border.all(
            color: goal.isReached ? AppTheme.success : AppTheme.goalColor,
            width: 2,
          ),
          boxShadow:
              goal.isReached ? AppTheme.magnetGlow(AppTheme.success) : null,
        ),
        child: Center(
          child: Icon(
            Icons.flag_rounded,
            color: goal.isReached ? AppTheme.success : AppTheme.goalColor,
            size: radius,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildObstacles(double scale) {
    return controller.obstacles.map((obstacle) {
      return Positioned(
        left: obstacle.position.x * scale,
        top: obstacle.position.y * scale,
        child: Container(
          width: obstacle.width * scale,
          height: obstacle.height * scale,
          decoration: BoxDecoration(
            color:
                obstacle.blocksPolarity
                    ? AppTheme.obstacleColor.withValues(alpha: 0.9)
                    : AppTheme.obstacleColor.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  obstacle.blocksPolarity
                      ? AppTheme.warning.withValues(alpha: 0.5)
                      : AppTheme.accent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              obstacle.blocksPolarity
                  ? Center(
                    child: Icon(
                      Icons.block,
                      color: AppTheme.warning.withValues(alpha: 0.3),
                      size:
                          math.min(obstacle.width, obstacle.height) *
                          scale *
                          0.5,
                    ),
                  )
                  : null,
        ),
      );
    }).toList();
  }

  List<Widget> _buildFixedMagnets(double scale) {
    return controller.fixedMagnets.map((magnet) {
      final color =
          magnet.polarity == Polarity.north
              ? AppTheme.northPole
              : AppTheme.southPole;
      final radius = GameConfig.magnetRadius * scale;

      return Positioned(
        left: magnet.position.x * scale - radius,
        top: magnet.position.y * scale - radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                magnet.isActive
                    ? color.withValues(alpha: 0.9)
                    : color.withValues(alpha: 0.3),
            border: Border.all(
              color: AppTheme.highlight,
              width: magnet.canToggle ? 3 : 2,
            ),
            boxShadow: magnet.isActive ? AppTheme.magnetGlow(color) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Polarity symbol
              Text(
                magnet.polarity.symbol,
                style: AppTheme.polaritySymbol.copyWith(fontSize: radius * 0.8),
              ),
              // Tap indicator if toggleable
              if (magnet.canToggle && controller.canToggle)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: radius * 0.5,
                    height: radius * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.highlight,
                      border: Border.all(color: color, width: 1),
                    ),
                    child: Icon(
                      Icons.touch_app,
                      size: radius * 0.3,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildMagneticObjects(double scale) {
    return controller.magneticObjects.map((obj) {
      final color =
          obj.polarity == Polarity.north
              ? AppTheme.northPole
              : AppTheme.southPole;
      final radius = GameConfig.objectRadius * scale;

      // Highlight goal object
      final isGoal = obj.isGoalObject;

      return Positioned(
        left: obj.position.x * scale - radius,
        top: obj.position.y * scale - radius,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.magneticObjectColor,
                AppTheme.magneticObjectColor.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: isGoal ? AppTheme.goalColor : color,
              width: isGoal ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isGoal ? AppTheme.goalColor : color).withValues(
                  alpha: 0.4,
                ),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              obj.polarity.symbol,
              style: AppTheme.polaritySymbol.copyWith(
                fontSize: radius * 0.7,
                color: color,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Paints grid lines on the game board.
class _GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;

  _GridPainter({required this.gridSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return gridSize != oldDelegate.gridSize || color != oldDelegate.color;
  }
}

/// Paints force lines between magnets and objects.
class _ForceLinesPainter extends CustomPainter {
  final List<MagneticObject> magneticObjects;
  final List<FixedMagnet> fixedMagnets;
  final double scale;

  _ForceLinesPainter({
    required this.magneticObjects,
    required this.fixedMagnets,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final obj in magneticObjects) {
      for (final magnet in fixedMagnets) {
        if (!magnet.isActive) continue;

        final isAttracting = obj.polarity.attractsWith(magnet.polarity);
        final color =
            isAttracting
                ? AppTheme.goalColor.withValues(alpha: 0.2)
                : AppTheme.warning.withValues(alpha: 0.2);

        final distance = obj.position.distanceTo(magnet.position);
        final maxDistance = 200.0;

        if (distance > maxDistance) continue;

        final opacity = (1 - distance / maxDistance) * 0.3;

        final paint =
            Paint()
              ..color = color.withValues(alpha: opacity)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke;

        final start = Offset(obj.position.x * scale, obj.position.y * scale);
        final end = Offset(
          magnet.position.x * scale,
          magnet.position.y * scale,
        );

        // Draw dashed line for repulsion, solid for attraction
        if (isAttracting) {
          canvas.drawLine(start, end, paint);
        } else {
          _drawDashedLine(canvas, start, end, paint);
        }
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 4.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / distance;
    final unitY = dy / distance;

    var currentDistance = 0.0;
    var drawing = true;

    while (currentDistance < distance) {
      final segmentLength = drawing ? dashLength : gapLength;
      final nextDistance = math.min(currentDistance + segmentLength, distance);

      if (drawing) {
        canvas.drawLine(
          Offset(
            start.dx + unitX * currentDistance,
            start.dy + unitY * currentDistance,
          ),
          Offset(
            start.dx + unitX * nextDistance,
            start.dy + unitY * nextDistance,
          ),
          paint,
        );
      }

      currentDistance = nextDistance;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _ForceLinesPainter oldDelegate) => true;
}
