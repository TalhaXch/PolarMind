import 'package:flutter/foundation.dart';
import '../../core/physics/physics_engine.dart';
import '../../core/physics/vector2d.dart';
import '../../core/config/game_config.dart';
import '../models/models.dart';

/// Controller for individual level gameplay.
class LevelController extends ChangeNotifier {
  final Level _originalLevel;
  late LevelState _state;
  late PhysicsEngine _physicsEngine;

  bool _isSimulating = false;
  DateTime? _startTime;

  LevelController(this._originalLevel) {
    _initializeLevel();
  }

  void _initializeLevel() {
    _state = LevelState(level: _originalLevel.copy());
    _physicsEngine = PhysicsEngine(
      worldBounds: _state.level.worldBounds,
      walls: _state.level.walls,
    );
    _startTime = null;
    _isSimulating = false;
  }

  // Getters
  Level get level => _state.level;
  LevelState get state => _state;
  bool get isCompleted => _state.isCompleted;
  bool get isPaused => _state.isPaused;
  bool get isSimulating => _isSimulating;
  int get toggleCount => _state.toggleCount;
  bool get canToggle => _state.canToggle;
  int get remainingToggles => _state.remainingToggles;
  bool get hasToggleLimit => _state.hasToggleLimit;

  Duration get elapsedTime {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  /// Get all fixed magnets
  List<FixedMagnet> get fixedMagnets => _state.level.fixedMagnets;

  /// Get all magnetic objects
  List<MagneticObject> get magneticObjects => _state.level.magneticObjects;

  /// Get all obstacles
  List<Obstacle> get obstacles => _state.level.obstacles;

  /// Get the goal zone
  GoalZone get goalZone => _state.level.goalZone;

  /// Toggle polarity of a magnet by ID
  bool toggleMagnet(String magnetId) {
    if (!canToggle) return false;

    final magnet =
        _state.level.fixedMagnets
            .where((m) => m.id == magnetId && m.canToggle)
            .firstOrNull;

    if (magnet == null) return false;

    magnet.toggle();
    _state.toggleCount++;

    // Start simulation on first interaction
    _startTime ??= DateTime.now();
    _isSimulating = true;

    notifyListeners();
    return true;
  }

  /// Set active state of a magnet
  bool setMagnetActive(String magnetId, bool active) {
    final magnet =
        _state.level.fixedMagnets.where((m) => m.id == magnetId).firstOrNull;

    if (magnet == null) return false;

    magnet.setActive(active);

    _startTime ??= DateTime.now();
    _isSimulating = true;

    notifyListeners();
    return true;
  }

  /// Update physics simulation
  void update(double deltaTime) {
    if (_state.isCompleted || _state.isPaused) return;

    // Collect magnetic bodies
    final magneticBodies =
        _state.level.magneticObjects.map((obj) {
          return MagneticBody(
            physics: obj.physics,
            polarity: obj.polarity,
            strength: obj.strength,
          );
        }).toList();

    // Collect magnet sources
    final magnetSources =
        _state.level.fixedMagnets.map((m) => m.toMagnetSource()).toList();

    // Run physics
    _physicsEngine.update(
      deltaTime: deltaTime,
      magneticBodies: magneticBodies,
      magnetSources: magnetSources,
    );

    // Check win condition
    _checkWinCondition();

    // Check if simulation should stop
    if (_physicsEngine.areAllBodiesAtRest(magneticBodies)) {
      _isSimulating = false;
    }

    notifyListeners();
  }

  void _checkWinCondition() {
    if (_state.isCompleted) return; // Already won

    final goalObject =
        _state.level.magneticObjects.where((o) => o.isGoalObject).firstOrNull;

    if (goalObject == null) return;

    final distanceToGoal = goalObject.position.distanceTo(
      _state.level.goalZone.position,
    );

    // Win immediately when object enters goal zone (regardless of speed)
    if (_state.level.goalZone.containsPoint(goalObject.position) ||
        distanceToGoal < GameConfig.goalSnapDistance) {
      // Snap ball to goal center and stop it
      goalObject.physics.position = _state.level.goalZone.position;
      goalObject.physics.velocity = Vector2D.zero;

      _state.isCompleted = true;
      _state.completionTime = elapsedTime;
      _state.level.goalZone.isReached = true;
      notifyListeners();
    }
  }

  /// Pause the game
  void pause() {
    _state.isPaused = true;
    notifyListeners();
  }

  /// Resume the game
  void resume() {
    _state.isPaused = false;
    notifyListeners();
  }

  /// Restart the level
  void restart() {
    _initializeLevel();
    notifyListeners();
  }

  /// Get hint for current level
  String? get hint => _originalLevel.hint;
}
