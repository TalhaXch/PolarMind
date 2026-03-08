// POLARMIND Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:polarmind/core/physics/vector2d.dart';
import 'package:polarmind/core/physics/magnet_force_calculator.dart';

void main() {
  group('Vector2D', () {
    test('addition works correctly', () {
      const a = Vector2D(1, 2);
      const b = Vector2D(3, 4);
      final result = a + b;
      expect(result.x, 4);
      expect(result.y, 6);
    });

    test('magnitude calculation', () {
      const v = Vector2D(3, 4);
      expect(v.magnitude, 5);
    });

    test('normalization', () {
      const v = Vector2D(3, 4);
      final normalized = v.normalized;
      expect(normalized.x, closeTo(0.6, 0.001));
      expect(normalized.y, closeTo(0.8, 0.001));
    });
  });

  group('MagnetForceCalculator', () {
    test('opposite poles attract', () {
      final force = MagnetForceCalculator.calculateForce(
        sourcePosition: const Vector2D(0, 0),
        targetPosition: const Vector2D(100, 0),
        sourcePolarity: Polarity.north,
        targetPolarity: Polarity.south,
        sourceStrength: 1.0,
        targetStrength: 1.0,
      );
      // Positive x means attraction toward source
      expect(force.x < 0, true);
    });

    test('like poles repel', () {
      final force = MagnetForceCalculator.calculateForce(
        sourcePosition: const Vector2D(0, 0),
        targetPosition: const Vector2D(100, 0),
        sourcePolarity: Polarity.north,
        targetPolarity: Polarity.north,
        sourceStrength: 1.0,
        targetStrength: 1.0,
      );
      // Negative x means repulsion away from source
      expect(force.x > 0, true);
    });
  });
}
