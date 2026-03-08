import 'dart:math' as math;
import '../config/game_config.dart';
import 'vector2d.dart';

/// Polarity enum for magnetic objects.
enum Polarity { north, south }

extension PolarityExtension on Polarity {
  bool attractsWith(Polarity other) => this != other;
  bool repelsWith(Polarity other) => this == other;

  String get symbol => this == Polarity.north ? '+' : '−';

  Polarity get opposite =>
      this == Polarity.north ? Polarity.south : Polarity.north;
}

/// Calculates magnetic forces between objects.
class MagnetForceCalculator {
  /// Calculate the force vector from source to target.
  /// Positive force = attraction (pull toward source)
  /// Negative force = repulsion (push away from source)
  static Vector2D calculateForce({
    required Vector2D sourcePosition,
    required Vector2D targetPosition,
    required Polarity sourcePolarity,
    required Polarity targetPolarity,
    required double sourceStrength,
    required double targetStrength,
  }) {
    final direction = sourcePosition - targetPosition;
    final distance = direction.magnitude;

    // Prevent division by zero and extreme forces at very close distances
    final clampedDistance = math.max(distance, GameConfig.minDistance);

    // Calculate force magnitude using inverse square law
    final forceMagnitude =
        (GameConfig.magneticConstant * sourceStrength * targetStrength) /
        math.pow(clampedDistance, GameConfig.forceDecayPower);

    // Clamp to prevent extreme forces
    final clampedForceMagnitude = math.min(forceMagnitude, GameConfig.maxForce);

    // Determine attraction or repulsion
    final isAttracting = sourcePolarity.attractsWith(targetPolarity);
    final forceDirection = isAttracting ? 1.0 : -1.0;

    // Return force vector
    if (distance < 0.001) return Vector2D.zero;
    return direction.normalized * clampedForceMagnitude * forceDirection;
  }

  /// Calculate combined force from multiple sources on a target.
  static Vector2D calculateCombinedForce({
    required Vector2D targetPosition,
    required Polarity targetPolarity,
    required double targetStrength,
    required List<MagnetSource> sources,
  }) {
    Vector2D totalForce = Vector2D.zero;

    for (final source in sources) {
      if (!source.isActive) continue;

      final force = calculateForce(
        sourcePosition: source.position,
        targetPosition: targetPosition,
        sourcePolarity: source.polarity,
        targetPolarity: targetPolarity,
        sourceStrength: source.strength,
        targetStrength: targetStrength,
      );

      totalForce = totalForce + force;
    }

    return totalForce.clampMagnitude(GameConfig.maxForce);
  }
}

/// Represents a source of magnetic force.
class MagnetSource {
  final Vector2D position;
  final Polarity polarity;
  final double strength;
  final bool isActive;

  const MagnetSource({
    required this.position,
    required this.polarity,
    this.strength = 1.0,
    this.isActive = true,
  });

  MagnetSource copyWith({
    Vector2D? position,
    Polarity? polarity,
    double? strength,
    bool? isActive,
  }) {
    return MagnetSource(
      position: position ?? this.position,
      polarity: polarity ?? this.polarity,
      strength: strength ?? this.strength,
      isActive: isActive ?? this.isActive,
    );
  }
}
