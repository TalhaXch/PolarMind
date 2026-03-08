import 'dart:math' as math;

/// A 2D vector class for physics calculations.
class Vector2D {
  final double x;
  final double y;

  const Vector2D(this.x, this.y);

  static const Vector2D zero = Vector2D(0, 0);

  double get magnitude => math.sqrt(x * x + y * y);
  double get magnitudeSquared => x * x + y * y;

  Vector2D get normalized {
    final mag = magnitude;
    if (mag == 0) return Vector2D.zero;
    return Vector2D(x / mag, y / mag);
  }

  Vector2D operator +(Vector2D other) => Vector2D(x + other.x, y + other.y);
  Vector2D operator -(Vector2D other) => Vector2D(x - other.x, y - other.y);
  Vector2D operator *(double scalar) => Vector2D(x * scalar, y * scalar);
  Vector2D operator /(double scalar) => Vector2D(x / scalar, y / scalar);
  Vector2D operator -() => Vector2D(-x, -y);

  double dot(Vector2D other) => x * other.x + y * other.y;

  double distanceTo(Vector2D other) => (this - other).magnitude;
  double distanceSquaredTo(Vector2D other) => (this - other).magnitudeSquared;

  Vector2D clampMagnitude(double maxMagnitude) {
    final mag = magnitude;
    if (mag <= maxMagnitude) return this;
    return normalized * maxMagnitude;
  }

  Vector2D lerp(Vector2D target, double t) {
    return Vector2D(x + (target.x - x) * t, y + (target.y - y) * t);
  }

  Vector2D reflect(Vector2D normal) {
    return this - normal * (2 * dot(normal));
  }

  @override
  String toString() => 'Vector2D($x, $y)';

  @override
  bool operator ==(Object other) =>
      other is Vector2D && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  Vector2D copyWith({double? x, double? y}) {
    return Vector2D(x ?? this.x, y ?? this.y);
  }
}
