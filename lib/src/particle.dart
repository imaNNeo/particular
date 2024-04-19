import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Two type of emitters (liner of radial)
enum EmitterType { gravity, radius }

/// Represents a particle in the particle system.
class Particle {
  /// Type of emitter (linear or radial).
  EmitterType emitterType = EmitterType.gravity;

  /// Time since particle instantiation.
  int age = 0;

  /// Initial speed of the particle.
  double speed = 0;

  /// Lifespan of the particle.
  int lifespan = 0;

  /// Size of the particle.
  double size = 100;

  /// Dynamic X position of the particle.
  double x = 0;

  /// Dynamic Y position of the particle.
  double y = 0;

  /// Dynamic rotation angle of the particle.
  double angle = 0;

  /// Dynamic radius of the particle.
  double radius = 0;

  /// Dynamic change in radius of the particle.
  double radiusDelta = 0;

  /// Dynamic X position of the emitter.
  double emitterX = 0;

  /// Dynamic Y position of the emitter.
  double emitterY = 0;

  /// Dynamic X velocity of the particle.
  double velocityX = 0;

  /// Dynamic Y velocity of the particle.
  double velocityY = 0;

  /// Dynamic X gravity of the particle.
  double gravityX = 0;

  /// Dynamic Y gravity of the particle.
  double gravityY = 0;

  /// Initial size of the particle.
  double startSize = 0;

  /// Final size of the particle.
  double finishSize = 0;

  /// Minimum radius of the particle.
  double minRadius = 0;

  /// Maximum radius of the particle.
  double maxRadius = 0;

  /// Rotation per second of the particle.
  double rotatePerSecond = 0;

  /// Radial acceleration of the particle.
  double radialAcceleration = 0;

  /// Tangential acceleration of the particle.
  double tangentialAcceleration = 0;

  /// Color of the particle.
  ParticleColor color = ParticleColor(0);

  /// Transform of the particle.
  ParticleTransform transform = ParticleTransform(0, 0, 0, 0);

  /// Initial color of the particle.
  Color startColor = Colors.white;

  /// Final color of the particle.
  Color finishColor = Colors.white;

  /// Initializes particle properties.
  void initialize({
    EmitterType emitterType = EmitterType.gravity,
    required int age,
    required int lifespan,
    required double speed,
    required double angle,
    required double emitterX,
    required double emitterY,
    required double startSize,
    required double finishSize,
    required Color startColor,
    required Color finishColor,
    double rotatePerSecond = 0,
    double radialAcceleration = 0,
    double tangentialAcceleration = 0,
    double minRadius = 0,
    double maxRadius = 0,
    double gravityX = 0,
    double gravityY = 0,
  }) {
    this.emitterType = emitterType;
    this.age = age;
    this.lifespan = lifespan;
    this.speed = speed;
    this.angle = angle;
    this.emitterX = emitterX;
    this.emitterY = emitterY;
    this.startSize = startSize;
    this.finishSize = finishSize;
    this.startColor = startColor;
    this.finishColor = finishColor;
    this.rotatePerSecond = rotatePerSecond;
    this.radialAcceleration = radialAcceleration;
    this.tangentialAcceleration = tangentialAcceleration;
    this.minRadius = minRadius;
    this.maxRadius = maxRadius;
    this.gravityX = gravityX;
    this.gravityY = gravityY;

    age = 0;
    x = emitterX;
    y = emitterY;
    size = startSize;
    color.update(
        startColor.alpha, startColor.red, startColor.green, startColor.blue);
    radius = maxRadius;
    radiusDelta = (minRadius - maxRadius);
    velocityX = speed * math.cos(angle / 180.0 * math.pi);
    velocityY = speed * math.sin(angle / 180.0 * math.pi);
  }

  /// Updates the particle's transform before adding to atlas.
  void update(int deltaTime) {
    if (isDead()) return;
    age += deltaTime;
    final ratio = age / lifespan;
    final rate = deltaTime / lifespan;

    angle -= rotatePerSecond * rate;

    if (emitterType == EmitterType.radius) {
      radius += radiusDelta * rate;
      final radiusCos = math.cos(angle / 180.0 * math.pi);
      final radiusSin = math.sin(angle / 180.0 * math.pi);
      x = emitterX - radiusCos * radius;
      y = emitterY - radiusSin * radius;
    } else {
      final distanceX = x - emitterX;
      final distanceY = y - emitterY;
      final distanceScalar =
          math.sqrt(distanceX * distanceX + distanceY * distanceY);
      final distanceScalarClamp = distanceScalar < 0.01 ? 0.01 : distanceScalar;

      final radialX = distanceX / distanceScalarClamp;
      final radialY = distanceY / distanceScalarClamp;

      final radialXModified = radialX * radialAcceleration;
      final radialYModified = radialY * radialAcceleration;

      final tangentialX = radialX;
      final tangentialY = radialY;

      final tangentialXModified = -tangentialY * tangentialAcceleration;
      final tangentialYModified = tangentialX * tangentialAcceleration;

      velocityX += rate * (gravityX + radialXModified + tangentialXModified);
      velocityY += rate * (gravityY + radialYModified + tangentialYModified);

      x += velocityX * rate;
      y += velocityY * rate;
    }

    color.lerp(startColor, finishColor, ratio);
    size = startSize + (finishSize - startSize) * ratio;
  }

  /// Return true if finished its life and reserved in pooling system
  bool isDead() {
    return age > lifespan;
  }
}

/// Dedicated transform class for pooling system
/// Help to reuse transforms after rendering
/// A transform class for particles in pooling system.
class ParticleTransform extends RSTransform {
  /// Scaled cosine of transform.
  double _scaledCos = 0;

  /// Scaled sine of transform.
  double _scaledSin = 0;

  /// Translate value in x
  double _tx = 0;

  /// Translate value in y
  double _ty = 0;

  /// Creates a new particle transform.
  ParticleTransform(super.scos, super.ssin, super.tx, super.ty);

  /// Update all transform specs
  void update({
    required double rotation,
    required double scale,
    required double anchorX,
    required double anchorY,
    required double translateX,
    required double translateY,
  }) {
    _scaledCos = math.cos(rotation) * scale;
    _scaledSin = math.sin(rotation) * scale;
    _tx = translateX - _scaledCos * anchorX + _scaledSin * anchorY;
    _ty = translateY - _scaledSin * anchorX - _scaledCos * anchorY;
  }

  /// The cosine of the rotation multiplied by the scale factor.
  @override
  double get scos => _scaledCos;

  /// The sine of the rotation multiplied by that same scale factor.
  @override
  double get ssin => _scaledSin;

  /// The x coordinate of the translation, minus [scos] multiplied by the
  /// x-coordinate of the rotation point, plus [ssin] multiplied by the
  /// y-coordinate of the rotation point.
  @override
  double get tx => _tx;

  /// The y coordinate of the translation, minus [ssin] multiplied by the
  /// x-coordinate of the rotation point, minus [scos] multiplied by the
  /// y-coordinate of the rotation point.
  @override
  double get ty => _ty;
}

/// Dedicated color class for pooling system
/// Help to reuse colors after rendering
class ParticleColor extends Color {
  @override
  // ignore: overridden_fields
  int value = 0;

  ParticleColor(super.value);

  /// Updates the color channels separately.
  ///
  /// The parameters [a], [r], [g], and [b] represent the alpha, red, green,
  /// and blue color channels respectively. Each channel is expected to be a
  /// value between 0 and 255.
  ///
  /// The color value of this [ParticleColor] object is updated with the
  /// provided color channels.
  void update(int a, int r, int g, int b) {
    // Combine the color channels into a single integer value.
    value = (((a & 0xff) <<
                24) | // Shift alpha channel and bitwise AND with 0xff
            ((r & 0xff) << 16) | // Shift red channel and bitwise AND with 0xff
            ((g & 0xff) << 8) | // Shift green channel and bitwise AND with 0xff
            ((b & 0xff) << 0)) & // Shift blue channel and bitwise AND with 0xff
        0xFFFFFFFF; // Mask the result to 32 bits
  }

  /// Linearly interpolates the color channels of this [ParticleColor]
  /// instance between the provided [from] and [to] colors using the
  /// given interpolation [delta].
  ///
  /// The color channels are interpolated separately using the [_lerpInt]
  /// function. The resulting interpolated color channels are then used to
  /// update the color of this [ParticleColor] instance using the [update]
  /// method.
  ///
  /// Parameters:
  ///   - from: The starting color.
  ///   - to: The ending color.
  ///   - delta: The interpolation factor.
  void lerp(Color from, Color to, double delta) {
    update(
      _clampInt(_lerpInt(from.alpha, to.alpha, delta).toInt(), 0, 255),
      _clampInt(_lerpInt(from.red, to.red, delta).toInt(), 0, 255),
      _clampInt(_lerpInt(from.green, to.green, delta).toInt(), 0, 255),
      _clampInt(_lerpInt(from.blue, to.blue, delta).toInt(), 0, 255),
    );
  }

  /// Linearly interpolates between two integers.
  ///
  /// The function takes in the starting integer [from], the ending integer
  /// [to], and the interpolation factor [delta]. It returns the interpolated
  /// value as a [double].
  ///
  /// Parameters:
  ///   - from: The starting integer.
  ///   - to: The ending integer.
  ///   - delta: The interpolation factor.
  ///
  /// Returns:
  ///   The interpolated value as a [double].
  double _lerpInt(int from, int to, double delta) => from + (to - from) * delta;

  /// Clamps the given [value] between the specified [min] and [max]
  /// boundaries.
  ///
  /// If [value] is less than [min], this function returns [min]. If [value] is
  /// greater than [max], this function returns [max]. Otherwise, it returns
  /// [value] itself.
  ///
  /// This method is a specialized version of [num.clamp] that is optimized for
  /// use with non-nullable [int] values.
  ///
  /// Parameters:
  ///   - [value]: The value to be clamped.
  ///   - [min]: The lower boundary of the range.
  ///   - [max]: The upper boundary of the range.
  ///
  /// Returns:
  ///   - The clamped value.
  int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  @override
  int get alpha => (0xff000000 & value) >> 24;

  /// The red channel of this color in an 8 bit value.
  @override
  int get red => (0x00ff0000 & value) >> 16;

  /// The green channel of this color in an 8 bit value.
  @override
  int get green => (0x0000ff00 & value) >> 8;

  /// The blue channel of this color in an 8 bit value.
  @override
  int get blue => (0x000000ff & value) >> 0;
}
