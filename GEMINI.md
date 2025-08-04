# Pachinko Game Design Document

## Overview
This document describes the architecture and implementation details of a Pachinko-style game. It covers both the original iOS implementation using SpriteKit and a new Flutter implementation. The game features a physics-based ball dropping mechanism where players score points when balls reach the bottom of the play area after bouncing through a field of pins.

## Architecture

### iOS Implementation (SpriteKit)

#### Core Components

#### GameScene (Primary Game Controller)
- **Framework**: SpriteKit (SKScene subclass)
- **Responsibilities**:
  - Initializes and manages all game elements
  - Handles touch input for ball launching
  - Manages physics world and collision detection
  - Updates score display
  - Controls game flow and animations

#### Physics System
- **Engine**: SpriteKit Physics (built-in physics engine)
- **Collision Handling**: 
  - Uses SKPhysicsContactDelegate protocol
  - Implements didBegin contact method for collision detection
  - Assigns contactTestBitMask for selective collision reporting
- **Body Types**:
  - Static bodies for pins, borders, and fences (isDynamic = false)
  - Dynamic bodies for balls (isDynamic = true by default)

#### Game Elements

##### Pins
- **Shape**: Circular (SKShapeNode with circleOfRadius)
- **Physics**: Static circular physics bodies
- **Layout**: Staggered grid pattern using nested loops
  - X positions: Starting at 75, spaced 100 units apart
  - Y positions: Starting at 200, spaced 100 units apart
  - Staggering: X offset calculated using modulo operation on Y position
  - Radius: 5 units

##### Ball Launcher
- **Trigger**: touchesBegan method
- **Sprite**: Spaceship.png image (scaled to 15%)
- **Position**: Fixed at (605, 40)
- **Physics**: Dynamic circular body (radius 30)
- **Velocity**: Vertical impulse with randomization (3000-3300 units)

##### Borders and Fences
- **Bottom Border**: Edge chain physics body for score detection
- **Side Borders**: Edge chain forming complex path
- **Fences**: Static rectangular bodies (5x75) spaced 100 units apart

##### Scoring System
- **Points**: +10 per ball reaching bottom
- **Display**: SKLabelNode updated in real-time
- **Visual Feedback**: Floating "+10" animation when scoring

## Game Flow (iOS)

1. Scene initialization (didMove method)
   - Create all static elements (pins, borders, fences)
   - Setup physics world and collision delegate
   - Initialize score display

2. Player interaction
   - Touch anywhere on screen to launch ball
   - Ball given randomized vertical velocity

3. Physics simulation
   - Ball falls under gravity
   - Collides with pins and borders
   - Eventually reaches bottom border

4. Collision detection
   - didBegin method triggered when ball hits bottom
   - Score updated and displayed
   - Floating animation shows point gain
   - Ball fades out and is removed

## Technical Specifications (iOS)

### Coordinate System
- Origin (0,0) at bottom-left
- Positive X to the right
- Positive Y upward
- Scene dimensions: Configured in GameViewController

### Physics Properties
- Pins: Static, circular (radius 5)
- Balls: Dynamic, circular (radius 30)
- Fences: Static, rectangular (5x75)
- Borders: Static, edge chains

### Visual Elements
- Pins: White circular shapes
- Fences: White rectangular shapes
- Balls: Spaceship.png texture (15% scale)
- Background: Default black (inherited from SKView)

## Implementation Details (iOS)

### Pin Grid Generation
```swift
let pinRadius : CGFloat = 5
let pinSpacing  : CGFloat = 100
for x : CGFloat in stride(from: 75, to: 500, by: pinSpacing) {
    for y : CGFloat in stride(from: 200, to: 800, by: pinSpacing) {
        let sprite = SKShapeNode(circleOfRadius: pinRadius)
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: pinRadius)
        sprite.physicsBody!.isDynamic = false
        // straggered pins
        sprite.position.x = x + (y.truncatingRemainder(dividingBy: (pinSpacing * 2))) / 2
        sprite.position.y = y
        sprite.fillColor = UIColor.white
        self.addChild(sprite)
    }
}
```

### Ball Launching
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // launch a ball
    let sprite = SKSpriteNode(imageNamed:"Spaceship")
    
    sprite.xScale = 0.15
    sprite.yScale = 0.15
    
    sprite.position = CGPoint(x: 605, y: 40)
    
    sprite.physicsBody = SKPhysicsBody(circleOfRadius: 30)
    sprite.physicsBody!.contactTestBitMask = 1
    
    self.addChild(sprite)
    
    // give some randomless
    sprite.physicsBody!.velocity.dy = 3000 + CGFloat(arc4random()) * 300 / CGFloat(RAND_MAX);
}
```

### Collision Handling
```swift
func didBegin(_ contact: SKPhysicsContact) {
    if contact.bodyA == borderBottom?.physicsBody {
        let body = contact.bodyB
        
        // disable futher collision
        body.contactTestBitMask = 0
        
        let node = body.node
        
        // fade out
        node!.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 1),
            SKAction.removeFromParent()]))
        
        // update score
        score += 10
        let label = self.childNode(withName: "score") as! SKLabelNode
        label.text = String(score)
        
        // score float up from the ball
        let scoreUp = SKLabelNode(text: "+10")
        scoreUp.position = node!.position
        self.addChild(scoreUp)
        scoreUp.run(SKAction.sequence([
            SKAction.move(by: CGVector(dx: 0, dy: 50), duration: 1),
            SKAction.removeFromParent()
            ]))
    }
}
```

## Assets
- Spaceship.png: Primary ball texture
- Default colors: White for pins and fences

## Performance Considerations
- Uses optimized SpriteKit rendering (ignoresSiblingOrder = true)
- Efficient collision detection through contactTestBitMask
- Proper memory management with node removal after use
- Physics bodies configured as static where possible to reduce computation

---

### Flutter Implementation

#### Core Components

#### Game (Primary Game Controller)
- **Framework**: Flame Engine (Game class)
- **Responsibilities**:
  - Initializes and manages all game components
  - Handles tap input for ball launching
  - Manages physics world and collision detection (via Forge2D)
  - Updates score display
  - Controls game flow and animations

#### Physics System
- **Engine**: Forge2D (integrated with Flame via `flame_forge2d`)
- **Collision Handling**: 
  - Uses `ContactCallbacks` for collision detection
  - Bodies are assigned `Filter` properties for selective collision
- **Body Types**:
  - Static bodies for pins, borders, and fences (`BodyType.static`)
  - Dynamic bodies for balls (`BodyType.dynamic`)

#### Game Elements

##### Pins
- **Shape**: Circular (`CircleComponent` or custom `PositionComponent` with `CircleHitbox`)
- **Physics**: Static circular physics bodies (`BodyComponent` from `flame_forge2d`)
- **Layout**: Staggered grid pattern using nested loops
  - X positions: Starting at 75, spaced 100 units apart
  - Y positions: Starting at 200, spaced 100 units apart
  - Staggering: X offset calculated using modulo operation on Y position
  - Radius: 5 units

##### Ball Launcher
- **Trigger**: `TapCallbacks` on the game area
- **Sprite**: Spaceship.png image (loaded as `SpriteComponent`)
- **Position**: Fixed at (605, 40)
- **Physics**: Dynamic circular body (`BodyComponent` from `flame_forge2d`, radius 30)
- **Velocity**: Vertical impulse with randomization (3000-3300 units, adjusted for Forge2D scale)

##### Borders and Fences
- **Bottom Border**: Static edge chain physics body (`EdgeBodyComponent` or `ChainBodyComponent`) for score detection
- **Side Borders**: Static edge chain forming complex path (`EdgeBodyComponent` or `ChainBodyComponent`)
- **Fences**: Static rectangular bodies (`PolygonBodyComponent` or `RectangleBodyComponent`, 5x75) spaced 100 units apart

##### Scoring System
- **Points**: +10 per ball reaching bottom
- **Display**: `TextComponent` updated in real-time
- **Visual Feedback**: Custom `PositionComponent` with `TextComponent` for floating "+10" animation

## Game Flow (Flutter)

1. Game initialization (`onLoad` method of `Game` class)
   - Create all static elements (pins, borders, fences) as `BodyComponent`s
   - Setup physics world
   - Initialize score display (`TextComponent`)

2. Player interaction
   - Tap anywhere on screen to launch ball
   - Ball given randomized vertical velocity

3. Physics simulation
   - Ball falls under gravity (handled by Forge2D)
   - Collides with pins and borders
   - Eventually reaches bottom border

4. Collision detection
   - `ContactCallbacks` triggered when ball hits bottom border
   - Score updated and displayed
   - Floating animation shows point gain
   - Ball fades out and is removed (`RemoveEffect` or custom animation)

## Technical Specifications (Flutter)

### Coordinate System
- Origin (0,0) at top-left (default for Flame, can be adjusted)
- Positive X to the right
- Positive Y downward (default for Flame, can be adjusted)
- Scene dimensions: Configured by `GameWidget` or `FlameGame` viewport

### Physics Properties
- Pins: Static, circular (radius 5, adjusted for physics world scale)
- Balls: Dynamic, circular (radius 30, adjusted for physics world scale)
- Fences: Static, rectangular (5x75, adjusted for physics world scale)
- Borders: Static, edge chains

### Visual Elements
- Pins: White circular shapes (rendered via `ShapeComponent` or custom `PositionComponent`)
- Fences: White rectangular shapes (rendered via `ShapeComponent` or custom `PositionComponent`)
- Balls: Spaceship.png texture (loaded as `Sprite`)
- Background: Default black (can be set via `Game` background color)

## Implementation Details (Flutter)

### Pin Grid Generation
```dart
// Example structure, actual implementation will use Flame/Forge2D components
final pinRadius = 5.0;
final pinSpacing = 100.0;
for (double x = 75; x < 500; x += pinSpacing) {
    for (double y = 200; y < 800; y += pinSpacing) {
        final position = Vector2(x + (y % (pinSpacing * 2)) / 2, y);
        world.add(Pin(position, pinRadius)); // Pin is a custom BodyComponent
    }
}
```

### Ball Launching
```dart
// Example structure, actual implementation will use Flame/Forge2D components
@override
void onTapDown(TapDownInfo info) {
    final ball = Ball(Vector2(605, 40)); // Ball is a custom BodyComponent
    world.add(ball);
    // Apply impulse, adjusting for Forge2D's smaller scale and units
    final impulse = Vector2(0, -(3000 + Random().nextDouble() * 300)); 
    ball.body.applyLinearImpulse(impulse);
}
```

### Collision Handling
```dart
// Example structure, actual implementation will use ContactCallbacks
class Ball extends BodyComponent with ContactCallbacks {
    // ...
    @override
    void beginContact(Object other, Contact contact) {
        if (other is BottomBorder) {
            // Disable further collision for this ball
            body.setAwake(false); // Or remove the body
            
            // Fade out and remove
            add(RemoveEffect(delay: 1.0)); // Flame effect
            
            // Update score
            gameRef.score.value += 10; // Assuming score is a ValueNotifier in Game
            
            // Floating score animation
            gameRef.add(FloatingScore(position)); // FloatingScore is a custom Component
        }
    }
}
```

## Assets
- Spaceship.png: Primary ball texture
- Default colors: White for pins and fences

## Performance Considerations
- Leverages Flame's optimized rendering and component system.
- Efficient collision detection through Forge2D.
- Proper memory management by removing components when no longer needed.
- Physics bodies configured as static where possible to reduce computation.