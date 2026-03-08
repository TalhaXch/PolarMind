# POLARMIND

A logic puzzle game based on magnetic attraction and repulsion. Master the physics of magnetism to solve increasingly challenging puzzles.

## Game Overview

POLARMIND challenges players to manipulate magnetic polarity to move objects, solve spatial puzzles, and reach goal states using cause-and-effect reasoning.

### Core Skills Tested
- Logical reasoning
- Spatial planning
- Physics intuition
- Prediction of outcomes

## Physics Model

### Magnetic Rules
- Every magnet has a polarity: **North (+)** or **South (−)**
- **Like poles repel** (+ repels +, − repels −)
- **Opposite poles attract** (+ attracts −)
- Forces follow inverse square falloff with distance
- All physics are deterministic and frame-rate independent

### Force Calculation
```
Force = (k × strength₁ × strength₂) / distance²
```
Where:
- `k` = magnetic constant (configurable)
- Force direction: positive for attraction, negative for repulsion
- Maximum force and velocity are clamped to prevent instability

## Architecture

```
lib/
├── core/
│   ├── config/          # Game configuration constants
│   ├── physics/         # Physics engine, force calculator, collision handler
│   └── validators/      # Level validation system
├── game/
│   ├── models/          # Game objects (magnets, obstacles, goals)
│   ├── controllers/     # Level and game state controllers
│   ├── services/        # Level service, persistence
│   └── data/            # Level definitions
└── ui/
    ├── theme/           # App-wide styling
    ├── screens/         # All app screens
    └── widgets/         # Game board and components
```

### Key Components
- **PhysicsEngine**: Central physics simulation with fixed timestep
- **MagnetForceCalculator**: Calculates magnetic forces between objects
- **LevelController**: Manages individual level gameplay
- **GameStateController**: Global state management using ChangeNotifier
- **LevelValidator**: Validates levels for solvability and stability

## Difficulty Tiers

1. **Beginner** (Levels 1-5): Single magnet interactions, basic toggle mechanics
2. **Intermediate** (Levels 6-10): Multiple magnets, chain reactions, obstacles
3. **Advanced** (Levels 11-15): Limited toggles, multiple balls, polarity blockers
4. **Expert** (Levels 16-20): Complex chains, precision puzzles, strategic planning

## How to Run

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK

### Installation
```bash
# Clone the repository
cd polarmind

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Controls
- **Tap a magnet** to toggle its polarity (when allowed)
- **Goal**: Guide the yellow ball to the green target zone
- Limited toggles in advanced levels require strategic planning

## License

Private project - All rights reserved
