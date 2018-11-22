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
    var gameScene : GameScene!
    enum GameState {
        case aiming, powering, shooting, dead
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
    
    
    
    
    var fingerlocation = CGPoint()
    
    var grids = true
    
    let nplayer = 2
    var numalive = 2
    var currentplayer = 0
    var ground = SKShapeNode()
    
    class player {
        

        let grids = true
        
        var radians : CGFloat = 0
        var power : CGFloat = 0
        var armor : CGFloat = 0
        
        var currentState = GameState.aiming
        
        var menu = SKSpriteNode()
        let bullet = SKSpriteNode(imageNamed: "bullet")
        let arrow = SKSpriteNode(imageNamed: "arrow")
        
        var tank = SKSpriteNode(imageNamed: "tank")
        //var tankShape = SKShapeNode()
        var bBullet = SKShapeNode()
        
        var labelangle = SKLabelNode()
        var labelpower = SKLabelNode()
        var labelarmor = SKLabelNode()
        
        
        func setBullet() {
            bullet.removeFromParent()
            bBullet.removeFromParent()
            bBullet.setScale(1)
            bBullet = SKShapeNode(rectOf: CGSize(width: 100, height: 30))
            bBullet.fillColor = grids ? .black : .clear
            bBullet.strokeColor = .clear
            bBullet.position = self.tank.position
            bBullet.zPosition = 3
            bullet.size = bBullet.frame.size
            bBullet.addChild(bullet)
            
            bBullet.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "bullet"), size: bullet.size)
            bBullet.physicsBody?.categoryBitMask = pc.bullet
            bBullet.physicsBody?.collisionBitMask = pc.ground
            bBullet.physicsBody?.contactTestBitMask = pc.tank
            bBullet.physicsBody?.affectedByGravity = true
            bBullet.physicsBody?.isDynamic = true
        }
        
        
        
    }

    
    var playernum: [player] = []
    
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
            playernum[currentplayer].setBullet()
            playernum[currentplayer].currentState = .aiming
        }
        
        // if body2.categoryBitMask == pc.tank {
        //     setBullet()
        // }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        while numalive > 1 {
            switch playernum[currentplayer].currentState {
            case .aiming:
                setArrow(player: playernum[currentplayer])
                for touch: AnyObject in touches {
                    fingerlocation = touch.location(in: self)
                }
            case .powering:
                print("powaaa")
            case .shooting:
                print("shooot")
            case .dead:
                print("tooot")
            }
            if currentplayer >= nplayer - 1 {
                currentplayer = 0
            }
            else {
                currentplayer += 1
            }
        }

        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        while numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                for touch: AnyObject in touches {
                    fingerlocation = touch.location(in: self)
                }
            case .powering:
                print("powaaa")
            case .shooting:
                print("shooot")
            case .dead:
                print("tooot")
            }
            if currentplayer >= nplayer - 1 {
                currentplayer = 0
            }
            else {
                currentplayer += 1
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        while numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                
                for touch: AnyObject in touches {
                    fingerlocation = touch.location(in: self)
                }
                playernum[currentplayer].radians = atan2(fingerlocation.y-playernum[currentplayer].tank.position.y, fingerlocation.x-playernum[currentplayer].tank.position.x)
                playernum[currentplayer].arrow.zRotation = playernum[currentplayer].radians
                playernum[currentplayer].currentState = .shooting
            case .powering:
                print("powaaa")
            case .shooting:
                print("shooot")
                fire(angle: Double(playernum[1].radians), vel: 100, player: playernum[1])
            case .dead:
                print("tooot")
            }
            if currentplayer >= nplayer - 1 {
                currentplayer = 0
            }
            else {
                currentplayer += 1
            }
        }
    }
    
    override func update (_ currentTime: CFTimeInterval) {
        while numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                playernum[currentplayer].radians = atan2(fingerlocation.y-playernum[currentplayer].tank.position.y, fingerlocation.x-playernum[currentplayer].tank.position.x)
                playernum[currentplayer].arrow.zRotation = playernum[currentplayer].radians
            case .powering:
                print("powaaa")
            case .shooting:
                print("shooot")
            case .dead:
                print("tooot")
            }
        }
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
        
        for i in 0...nplayer-1 {
            playernum.append(player())
            
            playernum[i].tank.setScale(0.3)
            playernum[i].tank.position = CGPoint(x: self.size.width*0.1, y: self.size.height*0.3)
            playernum[i].tank.zPosition = 4
            playernum[i].tank.physicsBody = SKPhysicsBody(rectangleOf: playernum[i].tank.size)
            playernum[i].tank.physicsBody!.affectedByGravity = false
            playernum[i].tank.physicsBody!.categoryBitMask = pc.tank
            playernum[i].tank.physicsBody!.collisionBitMask = pc.none
            playernum[i].tank.physicsBody!.contactTestBitMask = pc.bullet
            self.addChild(playernum[i].tank)
        }
        
        
        
       /* playernum[2].tank.setScale(0.3)
        playernum[2].tank.position = CGPoint(x: self.size.width*0.9, y: self.size.height*0.3)
        playernum[2].tank.zPosition = 4
        playernum[2].tank.physicsBody = SKPhysicsBody(rectangleOf: playernum[2].tank.size)
        playernum[2].tank.physicsBody!.affectedByGravity = false
        playernum[2].tank.physicsBody!.categoryBitMask = pc.tank
        playernum[2].tank.physicsBody!.collisionBitMask = pc.none
        playernum[2].tank.physicsBody!.contactTestBitMask = pc.bullet
        self.addChild(playernum[2].tank)
        
        */
        
        ground = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 5))
        ground.fillColor = .red
        ground.strokeColor = .clear
        ground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height * 2 / 10 - playernum[1].tank.frame.height / 2 - 5)
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
    
    
    func fire(angle: Double, vel: Double, player: player){
        player.setBullet()
        addChild(player.bBullet)
        player.arrow.removeFromParent()
        let x = vel * cos(angle)
        let y = vel * sin(angle)
        let shotVec = CGVector(dx: x, dy: y)
        player.bBullet.physicsBody?.applyImpulse(shotVec)
        
        //let wait4 = SKAction.wait(forDuration: 4)
        //let reset = SKAction.run({
        //    player.setBullet()
        //})
        //player.bBullet.run(SKAction.sequence([wait4, reset]))
    }
    func setArrow(player: player) {
        player.arrow.setScale(0.5)
        player.arrow.anchorPoint = CGPoint(x:0.5,y: 0)
        player.arrow.position = CGPoint(x: player.tank.position.x, y: player.tank.position.y)
        player.arrow.zPosition = 1
        addChild(player.arrow)
    }
    
    
}


