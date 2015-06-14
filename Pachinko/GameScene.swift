//
//  GameScene.swift
//  Pachinko
//
//  Created by Neo on 6/8/14.
//  Copyright (c) 2014 Neo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var borderBottom: SKShapeNode? = nil
    var score = 0
    
    override func didMoveToView(view: SKView) {
        let top = scene!.size.height;
        let right = scene!.size.width;
        
        // pins
        let pinRadius : CGFloat = 5
        let pinSpacing : CGFloat = 100
        for var x : CGFloat = 75; x < 500; x += pinSpacing {
            for var y : CGFloat = 200; y < 800; y += pinSpacing {
                let sprite = SKShapeNode(circleOfRadius: pinRadius)
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: pinRadius)
                sprite.physicsBody!.dynamic = false
                // straggered pins
                sprite.position.x = x + (y % (pinSpacing * 2)) / 2
                sprite.position.y = y
                sprite.fillColor = UIColor.whiteColor()
                self.addChild(sprite)
            }
        }
        
        // fences
        let fenceSpacing : CGFloat = 100
        let fenceSize = CGSize(width: 5, height: 75)
        for var x : CGFloat = fenceSpacing; x < right - 100; x += fenceSpacing {
            let sprite = SKShapeNode(rectOfSize: fenceSize)
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: fenceSize)
            sprite.physicsBody!.dynamic = false
            sprite.position = CGPoint(x: x, y: fenceSize.height / 2)
            sprite.fillColor = UIColor.whiteColor()
            self.addChild(sprite)
        }
        
        // bottom
        let pathBottom = CGPathCreateMutable()
        CGPathMoveToPoint(pathBottom, nil, 0, 0)
        CGPathAddLineToPoint(pathBottom, nil, right, 0)
        borderBottom = SKShapeNode(path: pathBottom)
        borderBottom!.physicsBody = SKPhysicsBody(edgeChainFromPath: pathBottom)
        borderBottom!.physicsBody!.dynamic = false
        self.addChild(borderBottom!)
        
        // other borders
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, 0, top)
        CGPathAddLineToPoint(path, nil, right - 150, top)
        CGPathAddLineToPoint(path, nil, right - 50, top - 50)
        CGPathAddLineToPoint(path, nil, right, top - 150)
        CGPathAddLineToPoint(path, nil, right, 0)
        let borders = SKShapeNode(path: path)
        borders.physicsBody = SKPhysicsBody(edgeChainFromPath: path)
        borders.physicsBody!.dynamic = false
        self.addChild(borders)
                
        // setup collision delegate
        self.physicsWorld.contactDelegate = self
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA == borderBottom?.physicsBody {
            let body = contact.bodyB
            
            // disable futher collision
            body.contactTestBitMask = 0
            
            let node = body.node
            
            // fade out
            node!.runAction(SKAction.sequence([
                SKAction.fadeAlphaTo(0, duration: 1),
                SKAction.removeFromParent()]))
            
            // update score
            score += 10
            let label = self.childNodeWithName("score") as! SKLabelNode
            label.text = String(score)
            
            // score float up from the ball
            let scoreUp = SKLabelNode(text: "+10")
            scoreUp.position = node!.position
            self.addChild(scoreUp)
            scoreUp.runAction(SKAction.sequence([
                SKAction.moveBy(CGVector(dx: 0, dy: 50), duration: 1),
                SKAction.removeFromParent()
                ]))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // launch a ball
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        
        sprite.xScale = 0.15
        sprite.yScale = 0.15
        
        sprite.position = CGPoint(x: 605, y: 40)
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        sprite.physicsBody!.contactTestBitMask = 1
        
        self.addChild(sprite)
        
        // give some randomless
        sprite.physicsBody!.velocity.dy = 3000 + CGFloat(rand()) * 300 / CGFloat(RAND_MAX);
    }
}
