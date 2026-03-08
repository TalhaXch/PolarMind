/// Central configuration for POLARMIND game physics and mechanics.
class GameConfig {
  // Physics constants
  static const double magneticConstant =
      500000.0; // Strong force for visible motion with proper physics
  static const double maxForce =
      800.0; // Higher max force for proper physics timestep integration
  static const double maxVelocity = 300.0;
  static const double friction = 0.95; // Moderate damping
  static const double minDistance = 35.0; // Prevent extreme close-range forces
  static const double forceDecayPower = 1.5; // Standard-ish falloff

  // Grid and sizing
  static const double gridSize = 40.0;
  static const double objectRadius = 18.0;
  static const double magnetRadius = 22.0;
  static const double goalRadius = 30.0;

  // Physics timing
  static const double fixedTimeStep = 1.0 / 60.0;
  static const int maxPhysicsSubSteps = 4;

  // Gameplay
  static const double goalSnapDistance = 25.0;
  static const double velocityThreshold =
      1.0; // Low threshold for smooth settling
  static const int maxSimulationSteps = 3000; // For level validation

  // Visual
  static const double forceLineOpacity = 0.3;
  static const double polarityIndicatorSize = 12.0;
}
