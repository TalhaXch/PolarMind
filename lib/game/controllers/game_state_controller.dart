import 'package:flutter/foundation.dart';
import '../services/level_service.dart';
import '../models/models.dart';

/// Global game state controller.
class GameStateController extends ChangeNotifier {
  final LevelService levelService;

  int? _currentLevelId;
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  GameStateController(this.levelService);

  // Getters
  int? get currentLevelId => _currentLevelId;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;

  LevelProgress get progress => levelService.progress;
  List<Level> get allLevels => levelService.allLevels;
  int get totalLevels => levelService.totalLevels;
  int get completedLevels => levelService.completedLevelCount;
  double get completionPercentage => levelService.completionPercentage;

  /// Set the current level being played
  void setCurrentLevel(int levelId) {
    _currentLevelId = levelId;
    notifyListeners();
  }

  /// Clear current level (back to menu)
  void clearCurrentLevel() {
    _currentLevelId = null;
    notifyListeners();
  }

  /// Get a specific level
  Level? getLevel(int id) => levelService.getLevel(id);

  /// Check if a level is unlocked
  bool isLevelUnlocked(int levelId) => levelService.isLevelUnlocked(levelId);

  /// Check if a level is completed
  bool isLevelCompleted(int levelId) => levelService.isLevelCompleted(levelId);

  /// Mark a level as completed
  Future<void> completeLevel(
    int levelId, {
    int? toggleCount,
    Duration? time,
  }) async {
    await levelService.markLevelCompleted(
      levelId,
      toggleCount: toggleCount,
      time: time,
    );
    notifyListeners();
  }

  /// Get levels by difficulty
  List<Level> getLevelsByDifficulty(DifficultyTier tier) =>
      levelService.getLevelsByDifficulty(tier);

  /// Toggle music
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    notifyListeners();
  }

  /// Toggle sound effects
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  /// Get the next level ID, or null if all completed
  int? getNextLevelId(int currentId) {
    if (currentId < totalLevels) {
      return currentId + 1;
    }
    return null;
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    await levelService.resetProgress();
    notifyListeners();
  }
}
