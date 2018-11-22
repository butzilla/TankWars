//
//  GameScene.swift
//  PanzerKrieg
//
//  Created by Johannes Conradi on 21.11.18.
//  Copyright © 2018 Johannes Conradi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum GameState {
        case aiming, powering, shooting
    }
    
    struct c {
        static var grav = CGFloat() // magnitude of the gravity
        static var vel = CGFloat() //velocity of the bullet
    }
    
    struct pc {
        static let none: UInt32 = 0x1 << 0
        static let bullet: UInt32 = 0x1 << 1
        static let ground: UInt32 = 0x1 << 2
        static let tank: UInt32 = 0x1 << 3
    }
    
    //let playerleft = SKSpriteNode(imageNamed: "playerleft")
    // let playerright = SKSpriteNode(imageNamed: "playerright")
    
    class player {
        var GameScene : GameScene!
        
        let grids = true
        
        var radians : CGFloat = 0
        var power : CGFloat = 0
        var armor : CGFloat = 0
        
        var current = GameState.aiming
        
        var menu = SKSpriteNode()
        let bullet = SKSpriteNode(imageNamed: "bullet")
        let arrow = SKSpriteNode(imageNamed: "arrow")
        
        var tank = SKSpriteNode(imageNamed: "tank")
        //var tankShape = SKShapeNode()
        //var bBullet = SKShapeNode()
        
        var labelangle = SKLabelNode()
        var labelpower = SKLabelNode()
        var labelarmor = SKLabelNode()
        
        
        func setBullet() {
            bullet.removeFromParent()
            //bBullet.removeFromParent()
            //bBullet.setScale(1)
            //bBullet = SKShapeNode(rectOf: CGSize(width: 100, height: 30))
            //bBullet.fillColor = grids ? .black : .clear
            //bBullet.strokeColor = .clear
            //bBullet.position = self.tank.position
            //bBullet.zPosition = 3
            //bullet.size = bBullet.frame.size
            //bBullet.addChild(bullet)
            
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
            bullet.physicsBody!.categoryBitMask = pc.bullet
            bullet.physicsBody!.collisionBitMask = pc.ground
            bullet.physicsBody!.contactTestBitMask = pc.tank
            bullet.physicsBody!.affectedByGravity = true
            bullet.physicsBody!.isDynamic = true
        }
        func fire(angle: Double, vel: Double){
            setBullet()
            //GameScene.addChild(bBullet)
            let x = vel * cos(angle)
            let y = vel * sin(angle)
            let shotVec = CGVector(dx: x, dy: y)
            bullet.physicsBody!.applyImpulse(shotVec)
            
            let wait4 = SKAction.wait(forDuration: 4)
            let reset = SKAction.run({
                self.setBullet()
            })
            self.bullet.run(SKAction.sequence([wait4, reset]))
        }
        func setArrow() {
            arrow.setScale(0.5)
            arrow.anchorPoint = CGPoint(x:0,y: 0.5)
            arrow.position = CGPoint(x: self.tank.position.x, y: self.tank.position.y)
            arrow.zPosition = 1
            self.addChild(arrow)
        }
        
    }
    
    
    
    
    var fingerlocation = CGPoint()
    
    var grids = true
    
    var ground = SKShapeNode()
    
    
    
    
    var one: player = player()
    var two: player = player()
    
    
    override func didMove(to view: SKView) {
        setUpGame()
    }
    
    func didBegin (_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
            
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body2.categoryBitMask == pc.ground {
            one.setBullet()
        }
        
        // if body2.categoryBitMask == pc.tank {
        //     setBullet()
        // }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            fingerlocation = touch.location(in: self)
            one.setArrow()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            fingerlocation = touch.location(in: self)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        one.fire(angle: Double(one.radians), vel: 100)
    }
    
    override func update (_ currentTime: CFTimeInterval) {
        one.radians = atan2(fingerlocation.x-one.tank.position.x, fingerlocation.y-one.tank.position.y)
        one.arrow.zRotation = -one.radians
    }
    
    func setUpGame() {
        self.physicsWorld.contactDelegate = self
        
        c.grav = -6
        c.vel = 100
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        
        one.tank.setScale(0.3)
        one.tank.position = CGPoint(x: self.size.width*0.1, y: self.size.height*0.3)
        one.tank.zPosition = 4
        one.tank.physicsBody = SKPhysicsBody(rectangleOf: one.tank.size)
        one.tank.physicsBody!.affectedByGravity = false
        one.tank.physicsBody!.categoryBitMask = pc.tank
        one.tank.physicsBody!.collisionBitMask = pc.none
        one.tank.physicsBody!.contactTestBitMask = pc.bullet
        self.addChild(one.tank)
        
        two.tank.setScale(0.3)
        two.tank.position = CGPoint(x: self.size.width*0.9, y: self.size.height*0.3)
        two.tank.zPosition = 4
        two.tank.physicsBody = SKPhysicsBody(rectangleOf: two.tank.size)
        two.tank.physicsBody!.affectedByGravity = false
        two.tank.physicsBody!.categoryBitMask = pc.tank
        two.tank.physicsBody!.collisionBitMask = pc.none
        two.tank.physicsBody!.contactTestBitMask = pc.bullet
        self.addChild(two.tank)
        
        
        
        ground = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        ground.fillColor = .red
        ground.strokeColor = .clear
        ground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 2 / 10 - one.tank.frame.height / 2 - 5)
        ground.zPosition = 1
        ground.alpha = grids ? 1 : 0
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.frame.size)
        ground.physicsBody!.categoryBitMask = pc.ground
        ground.physicsBody!.collisionBitMask = pc.none
        ground.physicsBody!.contactTestBitMask = pc.bullet
        ground.physicsBody!.affectedByGravity = false
        ground.physicsBody!.isDynamic = false
        ground.physicsBody!.friction = 1
        self.addChild(ground)
        //one.setBullet()
    }
    
    
    
    
    
}
