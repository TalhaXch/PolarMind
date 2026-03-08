import 'vector2d.dart';
import '../config/game_config.dart';

/// Represents a physics-enabled body in the game world.
class PhysicsBody {
  Vector2D position;
  Vector2D velocity;
  double mass;
  double radius;
  bool isStatic;
  bool isMagnetic;

  PhysicsBody({
    required this.position,
    this.velocity = Vector2D.zero,
    this.mass = 1.0,
    this.radius = GameConfig.objectRadius,
    this.isStatic = false,
    this.isMagnetic = true,
  });

  /// Apply a force to this body using proper physics with timestep
  void applyForce(
    Vector2D force, {
    double deltaTime = GameConfig.fixedTimeStep,
  }) {
    if (isStatic) return;
    // Proper physics: F = ma, so a = F/m, then v += a * dt
    final acceleration = force / mass;
    velocity = velocity + acceleration * deltaTime;
    velocity = velocity.clampMagnitude(GameConfig.maxVelocity);
  }

  /// Update position based on velocity
  void update(double deltaTime) {
    if (isStatic) return;

    // Apply friction/damping
    velocity = velocity * GameConfig.friction;

    // Stop if velocity is negligible
    if (velocity.magnitude < GameConfig.velocityThreshold) {
      velocity = Vector2D.zero;
    }

    // Update position
    position = position + velocity * deltaTime;
  }

  /// Check if this body is at rest
  bool get isAtRest => velocity.magnitude < GameConfig.velocityThreshold;

  /// Check collision with another body
  bool collidesWithBody(PhysicsBody other) {
    final distance = position.distanceTo(other.position);
    return distance < (radius + other.radius);
  }

  /// Check if a point is inside this body
  bool containsPoint(Vector2D point) {
    return position.distanceTo(point) < radius;
  }

  PhysicsBody copyWith({
    Vector2D? position,
    Vector2D? velocity,
    double? mass,
    double? radius,
    bool? isStatic,
    bool? isMagnetic,
  }) {
    return PhysicsBody(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      mass: mass ?? this.mass,
      radius: radius ?? this.radius,
      isStatic: isStatic ?? this.isStatic,
      isMagnetic: isMagnetic ?? this.isMagnetic,
    );
  }
}
