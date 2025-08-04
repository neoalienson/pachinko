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
    
    override func didMove(to view: SKView) {
        let top = scene!.size.height;
        let right = scene!.size.width;
        
        // pins
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
        
        // fences
        let fenceSpacing : CGFloat = 100
        let fenceSize = CGSize(width: 5, height: 75)
        for x : CGFloat in stride(from: fenceSpacing, to: right - 100, by: fenceSpacing) {
            let sprite = SKShapeNode(rectOf: fenceSize)
            sprite.physicsBody = SKPhysicsBody(rectangleOf: fenceSize)
            sprite.physicsBody!.isDynamic = false
            sprite.position = CGPoint(x: x, y: fenceSize.height / 2)
            sprite.fillColor = UIColor.white
            self.addChild(sprite)
        }
        
        // bottom
        let pathBottom = CGMutablePath()
        pathBottom.move(to: CGPoint(x:0, y:0))
        pathBottom.addLine(to: CGPoint(x: right, y: 0), transform: CGAffineTransform.identity)
        borderBottom = SKShapeNode(path: pathBottom)
        borderBottom!.physicsBody = SKPhysicsBody(edgeChainFrom: pathBottom)
        borderBottom!.physicsBody!.isDynamic = false
        self.addChild(borderBottom!)
        
        // other borders
        let path = CGMutablePath()
        path.move(to: CGPoint(x:0, y:0))
        path.addLine(to: CGPoint(x: 0, y: top), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x: right - 150, y: top), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x: right - 50, y: top), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x: right, y: top - 150), transform: CGAffineTransform.identity)
        path.addLine(to: CGPoint(x: right, y: 0), transform: CGAffineTransform.identity)
        
        let borders = SKShapeNode(path: path)
        borders.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        borders.physicsBody!.isDynamic = false
        self.addChild(borders)
                
        // setup collision delegate
        self.physicsWorld.contactDelegate = self
    }
    
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
}
