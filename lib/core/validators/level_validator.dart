import '../physics/physics_engine.dart';
import '../config/game_config.dart';
import '../../game/models/level.dart';

/// Validation result for a level.
class ValidationResult {
  final bool isValid;
  final bool isSolvable;
  final bool hasStableStates;
  final bool hasNoInfiniteLoops;
  final List<String> issues;
  final int? solutionSteps;

  const ValidationResult({
    required this.isValid,
    required this.isSolvable,
    required this.hasStableStates,
    required this.hasNoInfiniteLoops,
    this.issues = const [],
    this.solutionSteps,
  });

  factory ValidationResult.valid({int? solutionSteps}) {
    return ValidationResult(
      isValid: true,
      isSolvable: true,
      hasStableStates: true,
      hasNoInfiniteLoops: true,
      solutionSteps: solutionSteps,
    );
  }

  factory ValidationResult.invalid(List<String> issues) {
    return ValidationResult(
      isValid: false,
      isSolvable: false,
      hasStableStates: false,
      hasNoInfiniteLoops: false,
      issues: issues,
    );
  }
}

/// Validates that levels are solvable and have stable states.
class LevelValidator {
  /// Validate a level for solvability and stability.
  static ValidationResult validate(Level level) {
    final issues = <String>[];

    // Check basic structure
    if (level.magneticObjects.isEmpty) {
      issues.add('Level has no magnetic objects');
    }

    final goalObjects = level.magneticObjects.where((o) => o.isGoalObject);
    if (goalObjects.isEmpty) {
      issues.add('Level has no goal object');
    }

    if (level.fixedMagnets.isEmpty) {
      issues.add('Level has no fixed magnets');
    }

    if (issues.isNotEmpty) {
      return ValidationResult.invalid(issues);
    }

    // Check for stable states by simulating
    final stabilityCheck = _checkStability(level);
    if (!stabilityCheck.stable) {
      issues.add('Level does not reach stable state: ${stabilityCheck.reason}');
    }

    // Try to find a solution path
    final solvabilityCheck = _checkSolvability(level);
    if (!solvabilityCheck.solvable) {
      issues.add('Level may not be solvable');
    }

    if (issues.isNotEmpty) {
      return ValidationResult(
        isValid: false,
        isSolvable: solvabilityCheck.solvable,
        hasStableStates: stabilityCheck.stable,
        hasNoInfiniteLoops: stabilityCheck.stable,
        issues: issues,
      );
    }

    return ValidationResult.valid(solutionSteps: solvabilityCheck.steps);
  }

  static _StabilityResult _checkStability(Level level) {
    // Create a physics engine with level's bounds
    final engine = PhysicsEngine(
      worldBounds: level.worldBounds,
      walls: level.walls,
    );

    // Copy level state for simulation
    final testLevel = level.copy();
    final magneticBodies =
        testLevel.magneticObjects
            .map(
              (obj) => MagneticBody(
                physics: obj.physics,
                polarity: obj.polarity,
                strength: obj.strength,
              ),
            )
            .toList();

    final magnetSources =
        testLevel.fixedMagnets.map((m) => m.toMagnetSource()).toList();

    // Simulate
    final result = engine.simulateUntilEquilibrium(
      magneticBodies: magneticBodies,
      magnetSources: magnetSources,
    );

    if (!result.reachedEquilibrium) {
      return _StabilityResult(
        stable: false,
        reason: 'Did not reach equilibrium within ${result.steps} steps',
      );
    }

    // Check objects aren't stuck in walls or off-screen
    for (final body in magneticBodies) {
      if (!level.worldBounds.containsPoint(body.physics.position)) {
        return _StabilityResult(
          stable: false,
          reason: 'Object moved off-screen',
        );
      }
    }

    return _StabilityResult(stable: true);
  }

  static _SolvabilityResult _checkSolvability(Level level) {
    // Simple check: simulate with all polarity combinations
    // For complex levels, this would use a more sophisticated solver

    final toggleableMagnets =
        level.fixedMagnets.where((m) => m.canToggle).toList();

    if (toggleableMagnets.isEmpty) {
      // No toggleable magnets - check if goal is reachable with current state
      return _simulateAndCheckGoal(level);
    }

    // Try different polarity combinations (limited for performance)
    final maxCombinations = 1 << toggleableMagnets.length;
    final combinationsToTry = maxCombinations.clamp(1, 16);

    for (int i = 0; i < combinationsToTry; i++) {
      final testLevel = level.copy();

      // Set polarities based on binary representation of i
      for (int j = 0; j < toggleableMagnets.length && j < 4; j++) {
        if ((i & (1 << j)) != 0) {
          testLevel.fixedMagnets[j].toggle();
        }
      }

      final result = _simulateAndCheckGoal(testLevel);
      if (result.solvable) {
        return result;
      }
    }

    return _SolvabilityResult(solvable: false, steps: 0);
  }

  static _SolvabilityResult _simulateAndCheckGoal(Level level) {
    final engine = PhysicsEngine(
      worldBounds: level.worldBounds,
      walls: level.walls,
    );

    final testLevel = level.copy();
    final magneticBodies =
        testLevel.magneticObjects
            .map(
              (obj) => MagneticBody(
                physics: obj.physics,
                polarity: obj.polarity,
                strength: obj.strength,
              ),
            )
            .toList();

    final magnetSources =
        testLevel.fixedMagnets.map((m) => m.toMagnetSource()).toList();

    int steps = 0;
    while (steps < GameConfig.maxSimulationSteps) {
      engine.update(
        deltaTime: GameConfig.fixedTimeStep,
        magneticBodies: magneticBodies,
        magnetSources: magnetSources,
      );
      steps++;

      // Check if goal is reached
      final goalObject = magneticBodies.firstWhere(
        (b) => testLevel.magneticObjects.any(
          (o) => o.isGoalObject && o.physics == b.physics,
        ),
        orElse: () => magneticBodies.first,
      );

      if (testLevel.goalZone.containsPoint(goalObject.physics.position)) {
        return _SolvabilityResult(solvable: true, steps: steps);
      }

      // Check if equilibrium reached
      if (engine.areAllBodiesAtRest(magneticBodies)) {
        break;
      }
    }

    return _SolvabilityResult(solvable: false, steps: steps);
  }
}

class _StabilityResult {
  final bool stable;
  final String? reason;

  _StabilityResult({required this.stable, this.reason});
}

class _SolvabilityResult {
  final bool solvable;
  final int steps;

  _SolvabilityResult({required this.solvable, required this.steps});
}
