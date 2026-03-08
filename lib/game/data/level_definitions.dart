import '../../core/physics/vector2d.dart';
import '../../core/physics/magnet_force_calculator.dart';
import '../models/models.dart';

/// Contains all hand-crafted level definitions.
class LevelDefinitions {
  static List<Level> getAllLevels() {
    return [
      ..._beginnerLevels,
      ..._intermediateLevels,
      ..._advancedLevels,
      ..._expertLevels,
    ];
  }

  static List<Level> getLevelsByDifficulty(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.beginner:
        return _beginnerLevels;
      case DifficultyTier.intermediate:
        return _intermediateLevels;
      case DifficultyTier.advanced:
        return _advancedLevels;
      case DifficultyTier.expert:
        return _expertLevels;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BEGINNER LEVELS - Introduce core mechanics
  // ═══════════════════════════════════════════════════════════

  static final List<Level> _beginnerLevels = [
    // Level 1: Simple attraction
    Level(
      id: 1,
      name: 'First Pull',
      difficulty: DifficultyTier.beginner,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Opposite poles attract. Tap the magnet to change its polarity.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(160, 400),
          polarity: Polarity.south,
          strength: 1.5,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 150),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(160, 400)),
    ),

    // Level 2: Simple repulsion
    Level(
      id: 2,
      name: 'Push Away',
      difficulty: DifficultyTier.beginner,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Like poles repel. Push the ball to the goal.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 240),
          polarity: Polarity.north,
          strength: 1.2,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(120, 240),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 240)),
    ),

    // Level 3: Toggle to solve
    Level(
      id: 3,
      name: 'Toggle',
      difficulty: DifficultyTier.beginner,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Toggle the magnet polarity to attract the ball.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(160, 380),
          polarity: Polarity.north, // Starts repelling
          strength: 1.5,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 200),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(160, 380)),
    ),

    // Level 4: Two magnets
    Level(
      id: 4,
      name: 'Balance',
      difficulty: DifficultyTier.beginner,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Use both magnets to guide the ball.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 300),
          polarity: Polarity.north,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 300),
          polarity: Polarity.south,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 100),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 300)),
    ),

    // Level 5: Navigate around obstacle
    Level(
      id: 5,
      name: 'The Wall',
      difficulty: DifficultyTier.beginner,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'The ball must go around the wall.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(80, 200),
          polarity: Polarity.south,
          strength: 1.3,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(80, 380),
          polarity: Polarity.south,
          strength: 1.3,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(240, 100),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(
          id: 'wall_1',
          position: Vector2D(140, 120),
          width: 20,
          height: 160,
        ),
        Obstacle(
          id: 'wall_2',
          position: Vector2D(140, 320),
          width: 20,
          height: 160,
        ),
        Obstacle(
          id: 'wall_3',
          position: Vector2D(60, 240),
          width: 100,
          height: 15,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(80, 380)),
    ),
  ];

  // ═══════════════════════════════════════════════════════════
  // INTERMEDIATE LEVELS - More complex interactions
  // ═══════════════════════════════════════════════════════════

  static final List<Level> _intermediateLevels = [
    // Level 6: Chain reaction - vertical push
    Level(
      id: 6,
      name: 'Chain',
      difficulty: DifficultyTier.intermediate,
      gridWidth: 8,
      gridHeight: 12,
      hint:
          'Toggle the magnet to push the first ball, which pushes the second to the goal.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(160, 80),
          polarity: Polarity.south, // Starts attracting - toggle to repel
          strength: 1.5,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 180),
          polarity: Polarity.north,
        ),
        MagneticObject(
          id: 'ball_2',
          position: Vector2D(160, 280),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(160, 420)),
    ),

    // Level 7: Timing based on toggle
    Level(
      id: 7,
      name: 'Sequence',
      difficulty: DifficultyTier.intermediate,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Toggle at the right moment.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(160, 100),
          polarity: Polarity.south,
          strength: 1.2,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(160, 420),
          polarity: Polarity.north,
          strength: 1.2,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 260),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(160, 420)),
    ),

    // Level 8: Multiple paths
    Level(
      id: 8,
      name: 'Crossroads',
      difficulty: DifficultyTier.intermediate,
      gridWidth: 8,
      gridHeight: 12,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 240),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 240),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(160, 400),
          polarity: Polarity.north,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 100),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 400)),
    ),

    // Level 9: Precision positioning
    Level(
      id: 9,
      name: 'Narrow Pass',
      difficulty: DifficultyTier.intermediate,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Guide carefully through the gap.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(160, 340),
          polarity: Polarity.south,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 80),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(
          id: 'wall_1',
          position: Vector2D(0, 160),
          width: 110,
          height: 15,
        ),
        Obstacle(
          id: 'wall_2',
          position: Vector2D(210, 160),
          width: 110,
          height: 15,
        ),
        Obstacle(
          id: 'wall_3',
          position: Vector2D(80, 240),
          width: 160,
          height: 15,
        ),
        Obstacle(
          id: 'wall_4',
          position: Vector2D(0, 320),
          width: 110,
          height: 15,
        ),
        Obstacle(
          id: 'wall_5',
          position: Vector2D(210, 320),
          width: 110,
          height: 15,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(160, 400)),
    ),

    // Level 10: Redirect
    Level(
      id: 10,
      name: 'Redirect',
      difficulty: DifficultyTier.intermediate,
      gridWidth: 8,
      gridHeight: 12,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 100),
          polarity: Polarity.north,
          strength: 1.3,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(280, 280),
          polarity: Polarity.south,
          strength: 1.5,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 100),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(60, 400)),
    ),
  ];

  // ═══════════════════════════════════════════════════════════
  // ADVANCED LEVELS - Complex puzzle solving
  // ═══════════════════════════════════════════════════════════

  static final List<Level> _advancedLevels = [
    // Level 11: Limited toggles
    Level(
      id: 11,
      name: 'Conservation',
      difficulty: DifficultyTier.advanced,
      gridWidth: 8,
      gridHeight: 12,
      maxToggleCount: 5,
      hint: 'Use your toggles wisely.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(80, 200),
          polarity: Polarity.north,
          strength: 1.2,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(240, 200),
          polarity: Polarity.north,
          strength: 1.2,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(160, 400),
          polarity: Polarity.south,
          strength: 1.2,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 80),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(0, 140), width: 120, height: 15),
        Obstacle(
          id: 'w2',
          position: Vector2D(200, 140),
          width: 120,
          height: 15,
        ),
        Obstacle(
          id: 'w3',
          position: Vector2D(100, 240),
          width: 120,
          height: 15,
        ),
        Obstacle(id: 'w4', position: Vector2D(0, 320), width: 120, height: 15),
        Obstacle(
          id: 'w5',
          position: Vector2D(200, 320),
          width: 120,
          height: 15,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(160, 400)),
    ),

    // Level 12: Multi-ball
    Level(
      id: 12,
      name: 'Duo',
      difficulty: DifficultyTier.advanced,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'Both balls affect each other.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(80, 380),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(240, 380),
          polarity: Polarity.north,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(120, 120),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
        MagneticObject(
          id: 'ball_2',
          position: Vector2D(200, 120),
          polarity: Polarity.south,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(150, 80), width: 20, height: 100),
        Obstacle(id: 'w2', position: Vector2D(0, 200), width: 110, height: 15),
        Obstacle(
          id: 'w3',
          position: Vector2D(210, 200),
          width: 110,
          height: 15,
        ),
        Obstacle(id: 'w4', position: Vector2D(80, 280), width: 160, height: 15),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(80, 380)),
    ),

    // Level 13: Maze
    Level(
      id: 13,
      name: 'Labyrinth',
      difficulty: DifficultyTier.advanced,
      gridWidth: 8,
      gridHeight: 12,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(40, 200),
          polarity: Polarity.south,
          strength: 0.8,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(280, 300),
          polarity: Polarity.south,
          strength: 0.8,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(40, 400),
          polarity: Polarity.south,
          strength: 1.2,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(280, 80),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(80, 0), width: 20, height: 140),
        Obstacle(
          id: 'w2',
          position: Vector2D(220, 100),
          width: 20,
          height: 140,
        ),
        Obstacle(id: 'w3', position: Vector2D(80, 220), width: 20, height: 140),
        Obstacle(
          id: 'w4',
          position: Vector2D(220, 340),
          width: 20,
          height: 140,
        ),
        Obstacle(id: 'w5', position: Vector2D(140, 160), width: 80, height: 15),
        Obstacle(id: 'w6', position: Vector2D(100, 300), width: 80, height: 15),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(40, 420)),
    ),

    // Level 14: Force balance
    Level(
      id: 14,
      name: 'Equilibrium',
      difficulty: DifficultyTier.advanced,
      gridWidth: 8,
      gridHeight: 12,
      maxToggleCount: 6,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 160),
          polarity: Polarity.north,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 160),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(160, 360),
          polarity: Polarity.north,
          strength: 1.5,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 160),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(80, 100), width: 160, height: 15),
        Obstacle(id: 'w2', position: Vector2D(0, 200), width: 100, height: 15),
        Obstacle(
          id: 'w3',
          position: Vector2D(220, 200),
          width: 100,
          height: 15,
        ),
        Obstacle(id: 'w4', position: Vector2D(60, 280), width: 200, height: 15),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 360)),
    ),

    // Level 15: Polarity blocker
    Level(
      id: 15,
      name: 'Shield',
      difficulty: DifficultyTier.advanced,
      gridWidth: 8,
      gridHeight: 12,
      hint: 'The dark wall blocks magnetic force.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 280),
          polarity: Polarity.south,
          strength: 2.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 280),
          polarity: Polarity.south,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 100),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(
          id: 'shield_1',
          position: Vector2D(100, 180),
          width: 20,
          height: 120,
          blocksPolarity: true,
        ),
        Obstacle(
          id: 'wall_1',
          position: Vector2D(0, 140),
          width: 80,
          height: 15,
        ),
        Obstacle(
          id: 'wall_2',
          position: Vector2D(200, 240),
          width: 120,
          height: 15,
        ),
        Obstacle(
          id: 'wall_3',
          position: Vector2D(100, 340),
          width: 120,
          height: 15,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 400)),
    ),
  ];

  // ═══════════════════════════════════════════════════════════
  // EXPERT LEVELS - Challenging puzzles
  // ═══════════════════════════════════════════════════════════

  static final List<Level> _expertLevels = [
    // Level 16: Complex chain
    Level(
      id: 16,
      name: 'Cascade',
      difficulty: DifficultyTier.expert,
      gridWidth: 8,
      gridHeight: 12,
      maxToggleCount: 6,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(40, 100),
          polarity: Polarity.north,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(280, 200),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(40, 300),
          polarity: Polarity.north,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_4',
          position: Vector2D(280, 400),
          polarity: Polarity.south,
          strength: 1.2,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 100),
          polarity: Polarity.north,
        ),
        MagneticObject(
          id: 'ball_2',
          position: Vector2D(160, 300),
          polarity: Polarity.south,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(100, 60), width: 120, height: 15),
        Obstacle(id: 'w2', position: Vector2D(0, 150), width: 120, height: 15),
        Obstacle(
          id: 'w3',
          position: Vector2D(200, 150),
          width: 120,
          height: 15,
        ),
        Obstacle(
          id: 'w4',
          position: Vector2D(100, 240),
          width: 120,
          height: 15,
        ),
        Obstacle(id: 'w5', position: Vector2D(0, 330), width: 120, height: 15),
        Obstacle(
          id: 'w6',
          position: Vector2D(200, 330),
          width: 120,
          height: 15,
        ),
        Obstacle(
          id: 'w7',
          position: Vector2D(155, 150),
          width: 15,
          height: 90,
          blocksPolarity: true,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(280, 400)),
    ),

    // Level 17: Precision with obstacles
    Level(
      id: 17,
      name: 'Needle',
      difficulty: DifficultyTier.expert,
      gridWidth: 8,
      gridHeight: 12,
      maxToggleCount: 5,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 100),
          polarity: Polarity.north,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 300),
          polarity: Polarity.south,
          strength: 1.2,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 100),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(0, 220), width: 110, height: 15),
        Obstacle(
          id: 'w2',
          position: Vector2D(210, 220),
          width: 110,
          height: 15,
        ),
        Obstacle(id: 'w3', position: Vector2D(0, 290), width: 110, height: 15),
        Obstacle(
          id: 'w4',
          position: Vector2D(210, 290),
          width: 110,
          height: 15,
        ),
        Obstacle(id: 'w5', position: Vector2D(0, 360), width: 110, height: 15),
        Obstacle(
          id: 'w6',
          position: Vector2D(210, 360),
          width: 110,
          height: 15,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(60, 420), radius: 25),
    ),

    // Level 18: Triple ball coordination
    Level(
      id: 18,
      name: 'Trinity',
      difficulty: DifficultyTier.expert,
      gridWidth: 8,
      gridHeight: 12,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 120),
          polarity: Polarity.north,
          strength: 0.9,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 120),
          polarity: Polarity.south,
          strength: 0.9,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(160, 350),
          polarity: Polarity.north,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(100, 200),
          polarity: Polarity.north,
        ),
        MagneticObject(
          id: 'ball_2',
          position: Vector2D(220, 200),
          polarity: Polarity.south,
        ),
        MagneticObject(
          id: 'ball_3',
          position: Vector2D(160, 80),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(0, 140), width: 110, height: 15),
        Obstacle(
          id: 'w2',
          position: Vector2D(210, 140),
          width: 110,
          height: 15,
        ),
        Obstacle(id: 'w3', position: Vector2D(80, 220), width: 160, height: 15),
        Obstacle(id: 'w4', position: Vector2D(0, 320), width: 110, height: 15),
        Obstacle(
          id: 'w5',
          position: Vector2D(210, 320),
          width: 110,
          height: 15,
        ),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 420)),
    ),

    // Level 19: Tactical navigation
    Level(
      id: 19,
      name: 'Tactics',
      difficulty: DifficultyTier.expert,
      gridWidth: 8,
      gridHeight: 12,
      maxToggleCount: 6,
      hint: 'Guide the ball through the maze using careful timing.',
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 120),
          polarity: Polarity.north,
          strength: 1.2,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 240),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(60, 360),
          polarity: Polarity.north,
          strength: 1.0,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 60),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(60, 100), width: 200, height: 15),
        Obstacle(id: 'w2', position: Vector2D(0, 170), width: 100, height: 15),
        Obstacle(
          id: 'w3',
          position: Vector2D(220, 170),
          width: 100,
          height: 15,
        ),
        Obstacle(id: 'w4', position: Vector2D(60, 240), width: 200, height: 15),
        Obstacle(id: 'w5', position: Vector2D(0, 310), width: 100, height: 15),
        Obstacle(
          id: 'w6',
          position: Vector2D(220, 310),
          width: 100,
          height: 15,
        ),
        Obstacle(id: 'w7', position: Vector2D(60, 380), width: 200, height: 15),
      ],
      goalZone: GoalZone(id: 'goal_1', position: Vector2D(260, 420)),
    ),

    // Level 20: Final challenge
    Level(
      id: 20,
      name: 'Mastery',
      difficulty: DifficultyTier.expert,
      gridWidth: 8,
      gridHeight: 12,
      maxToggleCount: 8,
      fixedMagnets: [
        FixedMagnet(
          id: 'magnet_1',
          position: Vector2D(60, 60),
          polarity: Polarity.north,
          strength: 0.8,
        ),
        FixedMagnet(
          id: 'magnet_2',
          position: Vector2D(260, 60),
          polarity: Polarity.south,
          strength: 0.8,
        ),
        FixedMagnet(
          id: 'magnet_3',
          position: Vector2D(60, 240),
          polarity: Polarity.south,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_4',
          position: Vector2D(260, 240),
          polarity: Polarity.north,
          strength: 1.0,
        ),
        FixedMagnet(
          id: 'magnet_5',
          position: Vector2D(60, 420),
          polarity: Polarity.south,
          strength: 1.5,
        ),
      ],
      magneticObjects: [
        MagneticObject(
          id: 'ball_1',
          position: Vector2D(160, 140),
          polarity: Polarity.north,
          isGoalObject: true,
        ),
      ],
      obstacles: [
        Obstacle(id: 'w1', position: Vector2D(80, 100), width: 160, height: 15),
        Obstacle(id: 'w2', position: Vector2D(0, 180), width: 100, height: 15),
        Obstacle(
          id: 'w3',
          position: Vector2D(220, 180),
          width: 100,
          height: 15,
        ),
        Obstacle(id: 'w4', position: Vector2D(60, 260), width: 200, height: 15),
        Obstacle(id: 'w5', position: Vector2D(0, 340), width: 100, height: 15),
        Obstacle(
          id: 'w6',
          position: Vector2D(220, 340),
          width: 100,
          height: 15,
        ),
      ],
      goalZone: GoalZone(
        id: 'goal_1',
        position: Vector2D(260, 420),
        radius: 25,
      ),
    ),
  ];
}
