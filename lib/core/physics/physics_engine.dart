import '../config/game_config.dart';
import 'physics_body.dart';
import 'collision_handler.dart';
import 'magnet_force_calculator.dart';

/// Central physics engine for POLARMIND.
/// Handles all physics simulation including magnetic forces, movement, and collisions.
class PhysicsEngine {
  final AABB worldBounds;
  final List<Wall> walls;

  double _accumulator = 0.0;

  PhysicsEngine({required this.worldBounds, this.walls = const []});

  /// Run physics simulation for the given delta time.
  /// Uses fixed timestep with accumulator for frame-rate independence.
  void update({
    required double deltaTime,
    required List<MagneticBody> magneticBodies,
    required List<MagnetSource> magnetSources,
  }) {
    // Cap delta time to prevent spiral of death
    final clampedDelta = deltaTime.clamp(0.0, 0.1);
    _accumulator += clampedDelta;

    int steps = 0;
    while (_accumulator >= GameConfig.fixedTimeStep &&
        steps < GameConfig.maxPhysicsSubSteps) {
      _simulateStep(magneticBodies, magnetSources);
      _accumulator -= GameConfig.fixedTimeStep;
      steps++;
    }
  }

  void _simulateStep(
    List<MagneticBody> magneticBodies,
    List<MagnetSource> magnetSources,
  ) {
    // Calculate and apply magnetic forces
    for (final body in magneticBodies) {
      if (body.physics.isStatic) continue;

      final force = MagnetForceCalculator.calculateCombinedForce(
        targetPosition: body.physics.position,
        targetPolarity: body.polarity,
        targetStrength: body.strength,
        sources: magnetSources,
      );

      body.physics.applyForce(force);
    }

    // Also calculate forces between magnetic bodies
    for (int i = 0; i < magneticBodies.length; i++) {
      for (int j = i + 1; j < magneticBodies.length; j++) {
        final bodyA = magneticBodies[i];
        final bodyB = magneticBodies[j];

        if (bodyA.physics.isStatic && bodyB.physics.isStatic) continue;

        final forceOnA = MagnetForceCalculator.calculateForce(
          sourcePosition: bodyB.physics.position,
          targetPosition: bodyA.physics.position,
          sourcePolarity: bodyB.polarity,
          targetPolarity: bodyA.polarity,
          sourceStrength: bodyB.strength,
          targetStrength: bodyA.strength,
        );

        if (!bodyA.physics.isStatic) {
          bodyA.physics.applyForce(forceOnA);
        }
        if (!bodyB.physics.isStatic) {
          bodyB.physics.applyForce(-forceOnA);
        }
      }
    }

    // Update positions
    for (final body in magneticBodies) {
      body.physics.update(GameConfig.fixedTimeStep);
    }

    // Resolve collisions with walls and world bounds
    for (final body in magneticBodies) {
      if (body.physics.isStatic) continue;

      final result = CollisionHandler.resolveWallCollision(
        body.physics,
        walls,
        worldBounds,
      );

      body.physics.position = result.position;
      body.physics.velocity = result.velocity;
    }

    // Resolve body-to-body collisions
    for (int i = 0; i < magneticBodies.length; i++) {
      for (int j = i + 1; j < magneticBodies.length; j++) {
        CollisionHandler.resolveBodyCollision(
          magneticBodies[i].physics,
          magneticBodies[j].physics,
        );
      }
    }
  }

  /// Check if all bodies are at rest
  bool areAllBodiesAtRest(List<MagneticBody> bodies) {
    return bodies.every((b) => b.physics.isStatic || b.physics.isAtRest);
  }

  /// Simulate until equilibrium or max steps reached
  SimulationResult simulateUntilEquilibrium({
    required List<MagneticBody> magneticBodies,
    required List<MagnetSource> magnetSources,
    int maxSteps = GameConfig.maxSimulationSteps,
  }) {
    int steps = 0;

    while (steps < maxSteps) {
      _simulateStep(magneticBodies, magnetSources);
      steps++;

      if (areAllBodiesAtRest(magneticBodies)) {
        return SimulationResult(reachedEquilibrium: true, steps: steps);
      }
    }

    return SimulationResult(reachedEquilibrium: false, steps: steps);
  }
}

/// A body with magnetic properties.
class MagneticBody {
  final PhysicsBody physics;
  Polarity polarity;
  double strength;

  MagneticBody({
    required this.physics,
    required this.polarity,
    this.strength = 1.0,
  });

  MagneticBody copyWith({
    PhysicsBody? physics,
    Polarity? polarity,
    double? strength,
  }) {
    return MagneticBody(
      physics: physics ?? this.physics,
      polarity: polarity ?? this.polarity,
      strength: strength ?? this.strength,
    );
  }
}

/// Result of a physics simulation
class SimulationResult {
  final bool reachedEquilibrium;
  final int steps;

  const SimulationResult({
    required this.reachedEquilibrium,
    required this.steps,
  });
}
