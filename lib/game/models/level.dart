import '../../core/physics/vector2d.dart';
import '../../core/physics/collision_handler.dart';
import '../../core/config/game_config.dart';
import 'game_objects.dart';

/// Difficulty tier for levels.
enum DifficultyTier { beginner, intermediate, advanced, expert }

extension DifficultyTierExtension on DifficultyTier {
  String get displayName {
    switch (this) {
      case DifficultyTier.beginner:
        return 'Beginner';
      case DifficultyTier.intermediate:
        return 'Intermediate';
      case DifficultyTier.advanced:
        return 'Advanced';
      case DifficultyTier.expert:
        return 'Expert';
    }
  }

  int get index {
    switch (this) {
      case DifficultyTier.beginner:
        return 0;
      case DifficultyTier.intermediate:
        return 1;
      case DifficultyTier.advanced:
        return 2;
      case DifficultyTier.expert:
        return 3;
    }
  }
}

/// Represents a game level.
class Level {
  final int id;
  final String name;
  final DifficultyTier difficulty;
  final double gridWidth; // In grid units
  final double gridHeight;
  final List<FixedMagnet> fixedMagnets;
  final List<MagneticObject> magneticObjects;
  final List<Obstacle> obstacles;
  final GoalZone goalZone;
  final int? maxToggleCount; // Optional limit on polarity toggles
  final String? hint;

  Level({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.gridWidth,
    required this.gridHeight,
    required this.fixedMagnets,
    required this.magneticObjects,
    required this.goalZone,
    this.obstacles = const [],
    this.maxToggleCount,
    this.hint,
  });

  /// Get pixel dimensions based on grid units
  double get pixelWidth => gridWidth * GameConfig.gridSize;
  double get pixelHeight => gridHeight * GameConfig.gridSize;

  /// Get walls from obstacles
  List<Wall> get walls {
    return obstacles
        .map(
          (o) => Wall.fromRect(
            o.position.x,
            o.position.y,
            o.width,
            o.height,
            blocksPolarity: o.blocksPolarity,
          ),
        )
        .toList();
  }

  /// Get world bounds
  AABB get worldBounds =>
      AABB(Vector2D.zero, Vector2D(pixelWidth, pixelHeight));

  /// Create a deep copy of the level state
  Level copy() {
    return Level(
      id: id,
      name: name,
      difficulty: difficulty,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      fixedMagnets: fixedMagnets.map((m) => m.copy()).toList(),
      magneticObjects: magneticObjects.map((m) => m.copy()).toList(),
      obstacles: obstacles.map((o) => o.copy()).toList(),
      goalZone: goalZone.copy(),
      maxToggleCount: maxToggleCount,
      hint: hint,
    );
  }
}

/// State of a level during gameplay.
class LevelState {
  final Level level;
  int toggleCount;
  bool isCompleted;
  bool isPaused;
  DateTime? startTime;
  Duration? completionTime;

  LevelState({
    required this.level,
    this.toggleCount = 0,
    this.isCompleted = false,
    this.isPaused = false,
    this.startTime,
    this.completionTime,
  });

  bool get hasToggleLimit => level.maxToggleCount != null;
  int get remainingToggles =>
      hasToggleLimit ? (level.maxToggleCount! - toggleCount) : -1;
  bool get canToggle => !hasToggleLimit || remainingToggles > 0;
}

/// Progress through levels.
class LevelProgress {
  final Map<int, bool> completedLevels;
  final Map<int, int> bestToggleCounts;
  final Map<int, Duration> bestTimes;
  int currentUnlockedLevel;

  LevelProgress({
    Map<int, bool>? completedLevels,
    Map<int, int>? bestToggleCounts,
    Map<int, Duration>? bestTimes,
    this.currentUnlockedLevel = 1,
  }) : completedLevels = completedLevels ?? {},
       bestToggleCounts = bestToggleCounts ?? {},
       bestTimes = bestTimes ?? {};

  bool isLevelUnlocked(int levelId) => levelId <= currentUnlockedLevel;
  bool isLevelCompleted(int levelId) => completedLevels[levelId] ?? false;

  void markLevelCompleted(int levelId, {int? toggleCount, Duration? time}) {
    completedLevels[levelId] = true;

    if (toggleCount != null) {
      if (!bestToggleCounts.containsKey(levelId) ||
          toggleCount < bestToggleCounts[levelId]!) {
        bestToggleCounts[levelId] = toggleCount;
      }
    }

    if (time != null) {
      if (!bestTimes.containsKey(levelId) || time < bestTimes[levelId]!) {
        bestTimes[levelId] = time;
      }
    }

    // Unlock next level
    if (levelId >= currentUnlockedLevel) {
      currentUnlockedLevel = levelId + 1;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'completedLevels': completedLevels.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'bestToggleCounts': bestToggleCounts.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'bestTimes': bestTimes.map(
        (k, v) => MapEntry(k.toString(), v.inMilliseconds),
      ),
      'currentUnlockedLevel': currentUnlockedLevel,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      completedLevels:
          (json['completedLevels'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as bool),
          ) ??
          {},
      bestToggleCounts:
          (json['bestToggleCounts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as int),
          ) ??
          {},
      bestTimes:
          (json['bestTimes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), Duration(milliseconds: v as int)),
          ) ??
          {},
      currentUnlockedLevel: json['currentUnlockedLevel'] as int? ?? 1,
    );
  }
}
