import '../../core/physics/vector2d.dart';
import '../../core/physics/magnet_force_calculator.dart';
import '../../core/physics/physics_body.dart';
import '../../core/config/game_config.dart';

/// Unique identifier for game objects.
typedef GameObjectId = String;

/// Base class for all game objects.
abstract class GameObject {
  final GameObjectId id;
  Vector2D position;

  GameObject({required this.id, required this.position});
}

/// A fixed magnet that the player can interact with (toggle polarity).
class FixedMagnet extends GameObject {
  Polarity polarity;
  double strength;
  bool isActive;
  bool canToggle;

  FixedMagnet({
    required super.id,
    required super.position,
    required this.polarity,
    this.strength = 1.0,
    this.isActive = true,
    this.canToggle = true,
  });

  MagnetSource toMagnetSource() {
    return MagnetSource(
      position: position,
      polarity: polarity,
      strength: strength,
      isActive: isActive,
    );
  }

  void toggle() {
    if (canToggle) {
      polarity = polarity.opposite;
    }
  }

  void setActive(bool active) {
    isActive = active;
  }

  FixedMagnet copy() {
    return FixedMagnet(
      id: id,
      position: position,
      polarity: polarity,
      strength: strength,
      isActive: isActive,
      canToggle: canToggle,
    );
  }
}

/// A movable magnetic object that responds to magnetic forces.
class MagneticObject extends GameObject {
  Polarity polarity;
  double strength;
  final PhysicsBody physics;
  bool isGoalObject; // If true, this object needs to reach the goal

  MagneticObject({
    required super.id,
    required super.position,
    required this.polarity,
    this.strength = 1.0,
    this.isGoalObject = false,
    double mass = 1.0,
  }) : physics = PhysicsBody(
         position: position,
         mass: mass,
         radius: GameConfig.objectRadius,
         isStatic: false,
         isMagnetic: true,
       );

  // Keep position synced with physics body
  @override
  Vector2D get position => physics.position;

  @override
  set position(Vector2D value) {
    physics.position = value;
  }

  MagneticObject copy() {
    final copy = MagneticObject(
      id: id,
      position: physics.position,
      polarity: polarity,
      strength: strength,
      isGoalObject: isGoalObject,
      mass: physics.mass,
    );
    copy.physics.velocity = physics.velocity;
    return copy;
  }
}

/// A non-magnetic obstacle.
class Obstacle extends GameObject {
  final double width;
  final double height;
  final bool blocksPolarity;

  Obstacle({
    required super.id,
    required super.position,
    required this.width,
    required this.height,
    this.blocksPolarity = false,
  });

  Obstacle copy() {
    return Obstacle(
      id: id,
      position: position,
      width: width,
      height: height,
      blocksPolarity: blocksPolarity,
    );
  }
}

/// The goal zone where the magnetic object must reach.
class GoalZone extends GameObject {
  final double radius;
  bool isReached;

  GoalZone({
    required super.id,
    required super.position,
    this.radius = GameConfig.goalRadius,
    this.isReached = false,
  });

  bool containsPoint(Vector2D point) {
    return position.distanceTo(point) < radius;
  }

  GoalZone copy() {
    return GoalZone(
      id: id,
      position: position,
      radius: radius,
      isReached: isReached,
    );
  }
}
