import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/level_definitions.dart';

/// Service for managing level data and progress persistence.
class LevelService {
  static const String _progressKey = 'level_progress';

  final List<Level> _levels;
  LevelProgress _progress;

  LevelService._internal(this._levels, this._progress);

  static Future<LevelService> create() async {
    final levels = LevelDefinitions.getAllLevels();
    final progress = await _loadProgress();
    return LevelService._internal(levels, progress);
  }

  List<Level> get allLevels => _levels;
  LevelProgress get progress => _progress;
  int get totalLevels => _levels.length;

  Level? getLevel(int id) {
    try {
      return _levels.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Level> getLevelsByDifficulty(DifficultyTier tier) {
    return _levels.where((l) => l.difficulty == tier).toList();
  }

  bool isLevelUnlocked(int levelId) => _progress.isLevelUnlocked(levelId);
  bool isLevelCompleted(int levelId) => _progress.isLevelCompleted(levelId);

  Future<void> markLevelCompleted(
    int levelId, {
    int? toggleCount,
    Duration? time,
  }) async {
    _progress.markLevelCompleted(levelId, toggleCount: toggleCount, time: time);
    await _saveProgress();
  }

  int? getBestToggleCount(int levelId) => _progress.bestToggleCounts[levelId];
  Duration? getBestTime(int levelId) => _progress.bestTimes[levelId];

  int get completedLevelCount =>
      _progress.completedLevels.values.where((v) => v).length;

  double get completionPercentage =>
      totalLevels > 0 ? completedLevelCount / totalLevels : 0;

  Future<void> resetProgress() async {
    _progress = LevelProgress();
    await _saveProgress();
  }

  static Future<LevelProgress> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_progressKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return LevelProgress.fromJson(json);
      }
    } catch (e) {
      debugPrint('Failed to load progress: $e');
    }
    return LevelProgress();
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_progress.toJson());
      await prefs.setString(_progressKey, jsonString);
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }
}
