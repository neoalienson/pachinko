import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'game.dart';

void main() {
  runApp(
    GameWidget(
      game: PachinkoGame(),
    ),
  );
}