import 'dart:math';

import 'package:flame/components.dart'; // Import all of flame/components.dart
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart' as forge2d; // Import all of forge2d with alias
import 'package:flutter/material.dart';
import 'package:flame/palette.dart';
import 'package:flame/extensions.dart';
import 'package:flame/text.dart'; // Import TextPaint

class PachinkoGame extends forge2d.Forge2DGame with TapCallbacks {
  PachinkoGame() : super(gravity: forge2d.Vector2(0, 1000.0));

  late TextComponent scoreText;
  int score = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set up camera
    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.position = forge2d.Vector2(size.x / 2, size.y / 2);

    // Add score display
    scoreText = TextComponent(
      text: 'Score: 0',
      position: forge2d.Vector2(10, 10),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: TextStyle(
          color: BasicPalette.white.color,
          fontSize: 24.0,
        ),
      ),
    );
    world.add(scoreText);

    // Add borders
    add(BottomBorder(gameRef: this));
    add(SideBorder(gameRef: this, isLeft: true));
    add(SideBorder(gameRef: this, isLeft: false));

    // Add fences
    final fenceWidth = 5.0;
    final fenceHeight = 75.0;
    final fenceSpacing = 100.0;
    for (double x = 100; x < size.x - 100; x += fenceSpacing) {
      add(Fence(forge2d.Vector2(x, size.y - fenceHeight / 2 - 20), fenceWidth, fenceHeight));
    }

    // Add pins
    final pinRadius = 5.0;
    final pinSpacing = 100.0;
    final minX = 75.0;
    final maxX = size.x - 75.0;
    final numColumns = ((maxX - minX) / pinSpacing).floor() + 1;
    final numColumnsToRemove = (numColumns / 3).floor();
    final effectiveMaxX = minX + (numColumns - numColumnsToRemove) * pinSpacing;

    for (double y = 200; y < size.y - 200; y += pinSpacing) {
      for (double x = minX; x < effectiveMaxX; x += pinSpacing) {
        final position = forge2d.Vector2(x + (y % (pinSpacing * 2)) / 2, y);
        add(Pin(position, pinRadius));
      }
    }
  }

  @override
  void onTapDown(TapDownEvent info) {
    final ball = Ball(forge2d.Vector2(size.x / 2, 50));
    world.add(ball);
    final impulse = forge2d.Vector2(0, (30 + Random().nextDouble() * 3) * -1);
    ball.body.applyLinearImpulse(impulse);
  }

  void increaseScore() {
    score += 10;
    scoreText.text = 'Score: $score';
  }
}

class Pin extends forge2d.BodyComponent<PachinkoGame> { // Specify generic type
  final forge2d.Vector2 _position;
  final double _radius;

  Pin(this._position, this._radius) : super(priority: 1);

  @override
  forge2d.Body createBody() {
    final shape = forge2d.CircleShape();
    shape.radius = _radius;

    final fixtureDef = forge2d.FixtureDef(shape, friction: 0.5, restitution: 0.7);
    final bodyDef = forge2d.BodyDef(position: _position, type: forge2d.BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = BasicPalette.white.color;
    canvas.drawCircle(Offset.zero, _radius, paint);
  }
}

class Ball extends forge2d.BodyComponent<PachinkoGame> with forge2d.ContactCallbacks { // Specify generic type
  final forge2d.Vector2 _position;
  late SpriteComponent spriteComponent;

  Ball(this._position) : super(priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await game.loadSprite('Spaceship.png');
    spriteComponent = SpriteComponent(
      sprite: sprite,
      size: forge2d.Vector2.all(60), // Adjust size as needed, original was radius 30
      anchor: Anchor.center,
    );
    add(spriteComponent);
  }

  @override
  forge2d.Body createBody() {
    final shape = forge2d.CircleShape();
    shape.radius = 30; // Original radius was 30

    final fixtureDef = forge2d.FixtureDef(shape, friction: 0.5, restitution: 0.7, density: 1.0);
    final bodyDef = forge2d.BodyDef(position: _position, type: forge2d.BodyType.dynamic);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, forge2d.Contact contact) { // Explicitly use forge2d.Contact
    if (other is BottomBorder) {
      game.increaseScore(); // Access game directly
      Future.delayed(const Duration(milliseconds: 100), () {
        world.remove(this);
      });
    }
  }
}

class BottomBorder extends forge2d.BodyComponent<PachinkoGame> { // Specify generic type
  final PachinkoGame gameRef;

  BottomBorder({required this.gameRef}) : super(priority: 0);

  @override
  forge2d.Body createBody() {
    final shape = forge2d.EdgeShape();
    shape.set(forge2d.Vector2(0, gameRef.size.y - 10), forge2d.Vector2(gameRef.size.x, gameRef.size.y - 10));

    final fixtureDef = forge2d.FixtureDef(shape, friction: 0.5, restitution: 0.0);
    final bodyDef = forge2d.BodyDef(position: forge2d.Vector2.zero(), type: forge2d.BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class SideBorder extends forge2d.BodyComponent<PachinkoGame> { // Specify generic type
  final PachinkoGame gameRef;
  final bool isLeft;

  SideBorder({required this.gameRef, required this.isLeft}) : super(priority: 0);

  @override
  forge2d.Body createBody() {
    final shape = forge2d.EdgeShape();
    if (isLeft) {
      shape.set(forge2d.Vector2(10, 0), forge2d.Vector2(10, gameRef.size.y));
    } else {
      shape.set(forge2d.Vector2(gameRef.size.x - 10, 0), forge2d.Vector2(gameRef.size.x - 10, gameRef.size.y));
    }

    final fixtureDef = forge2d.FixtureDef(shape, friction: 0.5, restitution: 0.0);
    final bodyDef = forge2d.BodyDef(position: forge2d.Vector2.zero(), type: forge2d.BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Fence extends forge2d.BodyComponent<PachinkoGame> { // Specify generic type
  final forge2d.Vector2 _position;
  final double _width;
  final double _height;

  Fence(this._position, this._width, this._height) : super(priority: 1);

  @override
  forge2d.Body createBody() {
    final shape = forge2d.PolygonShape();
    shape.setAsBox(_width / 2, _height / 2, forge2d.Vector2.zero(), 0);

    final fixtureDef = forge2d.FixtureDef(shape, friction: 0.5, restitution: 0.1);
    final bodyDef = forge2d.BodyDef(position: _position, type: forge2d.BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = BasicPalette.white.color;
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: _width, height: _height), paint);
  }
}
