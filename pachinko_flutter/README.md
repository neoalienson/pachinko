# Pachinko Game - Flutter Implementation

A cross-platform Pachinko-style pinball game built with Flutter, Flame engine, and Forge2D physics library.

## Overview

This implementation recreates the classic Pachinko gameplay using Flutter for cross-platform compatibility. The game features:
- Physics-based ball dropping mechanism
- Staggered pin grid for ball deflection
- Score tracking when balls reach the bottom
- Visual feedback for scoring events

## Getting Started

### Prerequisites
- Flutter SDK installed
- Basic knowledge of Flutter development

### Installation
1. Clone this repository
2. Navigate to the `pachinko_flutter` directory
3. Run `flutter pub get` to install dependencies

### Running the Game
```bash
flutter run
```

### Building for Release
```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## Architecture

The game is built using the Flame game engine with Forge2D physics integration:
- `PachinkoGame`: Main game class extending `Forge2DGame` with `TapCallbacks`
- `Pin`: Static circular physics bodies arranged in a staggered grid
- `Ball`: Dynamic circular physics bodies with sprite rendering
- `BottomBorder`, `SideBorder`: Static edge bodies for game boundaries
- `Fence`: Static rectangular bodies placed at the bottom

## Technical Details

For comprehensive technical documentation about both the iOS and Flutter implementations, please refer to the main [GEMINI.md](../GEMINI.md) document.

## Assets

- `Spaceship.png`: Texture used for the ball sprite
- All other visual elements are rendered programmatically

## Dependencies

- `flame`: Game engine for Flutter
- `flame_forge2d`: Physics engine integration
- `flutter`: UI toolkit

For a complete list of dependencies, see [pubspec.yaml](pubspec.yaml).
