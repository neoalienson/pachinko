//
//  GameScene.swift
//  Pachinko
//
//  Created by Neo on 6/8/14.
//  Copyright (c) 2014 Neo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var wallBottom: SKShapeNode? = nil
    
    override func didMoveToView(view: SKView) {
        // pins
        for var x : CGFloat = 75; x < 500; x += 100 {
            for var y : CGFloat = 200; y < 800; y += 100 {
                let radius : CGFloat = 5
                let sprite = SKShapeNode(circleOfRadius: radius)
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: radius)
                sprite.physicsBody.affectedByGravity = false
                sprite.physicsBody.dynamic = false
                sprite.position.x = x + (y % 200) / 2
                sprite.position.y = y
                sprite.fillColor = UIColor.whiteColor()
                self.addChild(sprite)
            }
        }
        
        // fences
        for var x : CGFloat = 100; x < 600; x += 100 {
            let size = CGSize(width: 5, height: 75)
            let sprite = SKShapeNode(rectOfSize: size)
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: size)
            sprite.physicsBody.affectedByGravity = false
            sprite.physicsBody.dynamic = false
            sprite.position.x = x
            sprite.position.y = size.height / 2
            sprite.fillColor = UIColor.whiteColor()
            self.addChild(sprite)
        }
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, 640, 0)
        wallBottom = SKShapeNode(path: path)
        wallBottom?.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: 640,y: 0))
        wallBottom?.physicsBody.dynamic = false
        self.addChild(wallBottom)
        
        // setup collision delegate
        self.physicsWorld.contactDelegate = self
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        if contact.bodyA == wallBottom?.physicsBody {
            let body = contact.bodyB
            
            // disable futher collision
            body.contactTestBitMask = 0
            
            let node = body.node
            
            let actions = [
                SKAction.fadeAlphaTo(0, duration: 1),
                SKAction.removeFromParent()]
            node.runAction(SKAction.sequence(actions))
            
            let actions2 = [
                SKAction.moveBy(CGVector(dx: 0, dy: 50), duration: 1),
                SKAction.removeFromParent()
            ]
            let score = SKLabelNode(text: "+10")
            score.position = node.position
            self.addChild(score)
            score.runAction(SKAction.sequence(actions2))
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        
        sprite.xScale = 0.15
        sprite.yScale = 0.15
        
        sprite.position.x = 605
        sprite.position.y = 40
        
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        sprite.physicsBody.affectedByGravity = true
        sprite.physicsBody.mass =  1
        sprite.physicsBody.contactTestBitMask = 1
        
        self.addChild(sprite)
        
        sprite.physicsBody.velocity.dy = 3000 + CGFloat(rand()) * 300 / CGFloat(RAND_MAX);
    }
}
