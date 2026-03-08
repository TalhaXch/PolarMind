import 'dart:math' as math;
import 'vector2d.dart';
import 'physics_body.dart';

/// Axis-Aligned Bounding Box for collision detection.
class AABB {
  final Vector2D min;
  final Vector2D max;

  const AABB(this.min, this.max);

  factory AABB.fromCenter(Vector2D center, double width, double height) {
    return AABB(
      Vector2D(center.x - width / 2, center.y - height / 2),
      Vector2D(center.x + width / 2, center.y + height / 2),
    );
  }

  bool containsPoint(Vector2D point) {
    return point.x >= min.x &&
        point.x <= max.x &&
        point.y >= min.y &&
        point.y <= max.y;
  }

  bool intersects(AABB other) {
    return min.x <= other.max.x &&
        max.x >= other.min.x &&
        min.y <= other.max.y &&
        max.y >= other.min.y;
  }

  Vector2D get center => Vector2D((min.x + max.x) / 2, (min.y + max.y) / 2);

  double get width => max.x - min.x;
  double get height => max.y - min.y;
}

/// Wall obstacle in the game.
class Wall {
  final AABB bounds;
  final bool blocksPolarity; // If true, blocks magnetic forces through it

  const Wall(this.bounds, {this.blocksPolarity = false});

  factory Wall.fromRect(
    double x,
    double y,
    double width,
    double height, {
    bool blocksPolarity = false,
  }) {
    return Wall(
      AABB(Vector2D(x, y), Vector2D(x + width, y + height)),
      blocksPolarity: blocksPolarity,
    );
  }
}

/// Handles collision detection and resolution.
class CollisionHandler {
  /// Resolve collision between a body and walls.
  /// Returns the corrected position and velocity.
  static CollisionResult resolveWallCollision(
    PhysicsBody body,
    List<Wall> walls,
    AABB worldBounds,
  ) {
    Vector2D newPosition = body.position;
    Vector2D newVelocity = body.velocity;
    bool collided = false;

    // Check world bounds - low restitution to prevent oscillation
    const double bounceRestitution = 0.2;
    if (newPosition.x - body.radius < worldBounds.min.x) {
      newPosition = Vector2D(worldBounds.min.x + body.radius, newPosition.y);
      newVelocity = Vector2D(
        -newVelocity.x * bounceRestitution,
        newVelocity.y * 0.8,
      );
      collided = true;
    }
    if (newPosition.x + body.radius > worldBounds.max.x) {
      newPosition = Vector2D(worldBounds.max.x - body.radius, newPosition.y);
      newVelocity = Vector2D(
        -newVelocity.x * bounceRestitution,
        newVelocity.y * 0.8,
      );
      collided = true;
    }
    if (newPosition.y - body.radius < worldBounds.min.y) {
      newPosition = Vector2D(newPosition.x, worldBounds.min.y + body.radius);
      newVelocity = Vector2D(
        newVelocity.x * 0.8,
        -newVelocity.y * bounceRestitution,
      );
      collided = true;
    }
    if (newPosition.y + body.radius > worldBounds.max.y) {
      newPosition = Vector2D(newPosition.x, worldBounds.max.y - body.radius);
      newVelocity = Vector2D(
        newVelocity.x * 0.8,
        -newVelocity.y * bounceRestitution,
      );
      collided = true;
    }

    // Check wall collisions
    for (final wall in walls) {
      final result = _resolveAABBCircleCollision(
        newPosition,
        body.radius,
        wall.bounds,
      );
      if (result != null) {
        newPosition = result.position;
        newVelocity = _reflectVelocity(newVelocity, result.normal);
        collided = true;
      }
    }

    return CollisionResult(
      position: newPosition,
      velocity: newVelocity,
      collided: collided,
    );
  }

  /// Resolve collision between two bodies.
  static void resolveBodyCollision(PhysicsBody bodyA, PhysicsBody bodyB) {
    final direction = bodyB.position - bodyA.position;
    final distance = direction.magnitude;
    final minDistance = bodyA.radius + bodyB.radius;

    if (distance >= minDistance || distance < 0.001) return;

    final normal = direction.normalized;
    final overlap = minDistance - distance;

    if (bodyA.isStatic && !bodyB.isStatic) {
      bodyB.position = bodyB.position + normal * overlap;
    } else if (!bodyA.isStatic && bodyB.isStatic) {
      bodyA.position = bodyA.position - normal * overlap;
    } else if (!bodyA.isStatic && !bodyB.isStatic) {
      bodyA.position = bodyA.position - normal * (overlap / 2);
      bodyB.position = bodyB.position + normal * (overlap / 2);
    }

    // Exchange velocities along collision normal (elastic collision)
    if (!bodyA.isStatic && !bodyB.isStatic) {
      final relativeVelocity = bodyA.velocity - bodyB.velocity;
      final velocityAlongNormal = relativeVelocity.dot(normal);

      if (velocityAlongNormal > 0) return; // Bodies moving apart

      final restitution = 0.5;
      final impulse =
          -(1 + restitution) *
          velocityAlongNormal /
          (1 / bodyA.mass + 1 / bodyB.mass);

      bodyA.velocity = bodyA.velocity + normal * (impulse / bodyA.mass);
      bodyB.velocity = bodyB.velocity - normal * (impulse / bodyB.mass);
    } else if (bodyA.isStatic && !bodyB.isStatic) {
      bodyB.velocity = _reflectVelocity(bodyB.velocity, normal);
    } else if (!bodyA.isStatic && bodyB.isStatic) {
      bodyA.velocity = _reflectVelocity(bodyA.velocity, -normal);
    }
  }

  static _AABBCircleResult? _resolveAABBCircleCollision(
    Vector2D circleCenter,
    double radius,
    AABB box,
  ) {
    // Find closest point on AABB to circle
    final closestX = math.max(box.min.x, math.min(circleCenter.x, box.max.x));
    final closestY = math.max(box.min.y, math.min(circleCenter.y, box.max.y));
    final closest = Vector2D(closestX, closestY);

    final distance = circleCenter.distanceTo(closest);

    if (distance >= radius) return null;

    // Calculate push-out direction
    Vector2D normal;
    if (distance < 0.001) {
      // Circle center is inside box, push out to nearest edge
      final distToLeft = circleCenter.x - box.min.x;
      final distToRight = box.max.x - circleCenter.x;
      final distToTop = circleCenter.y - box.min.y;
      final distToBottom = box.max.y - circleCenter.y;

      final minDist = [
        distToLeft,
        distToRight,
        distToTop,
        distToBottom,
      ].reduce(math.min);

      if (minDist == distToLeft) {
        normal = const Vector2D(-1, 0);
      } else if (minDist == distToRight) {
        normal = const Vector2D(1, 0);
      } else if (minDist == distToTop) {
        normal = const Vector2D(0, -1);
      } else {
        normal = const Vector2D(0, 1);
      }
    } else {
      normal = (circleCenter - closest).normalized;
    }

    final penetration = radius - distance;
    final newPosition = circleCenter + normal * penetration;

    return _AABBCircleResult(newPosition, normal);
  }

  static Vector2D _reflectVelocity(Vector2D velocity, Vector2D normal) {
    return velocity - normal * (2 * velocity.dot(normal)) * 0.5;
  }
}

class _AABBCircleResult {
  final Vector2D position;
  final Vector2D normal;

  _AABBCircleResult(this.position, this.normal);
}

class CollisionResult {
  final Vector2D position;
  final Vector2D velocity;
  final bool collided;

  const CollisionResult({
    required this.position,
    required this.velocity,
    required this.collided,
  });
}
