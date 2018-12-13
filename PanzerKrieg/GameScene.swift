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
    var labelanzeige = SKLabelNode()
    var windlbl = SKLabelNode()

    var fingerlocation = CGPoint()
    
    var grids = true
    
    let nplayer = 5
    var numalive = 2
    var currentplayer = 0
    var wind = 0
    var ground = GroundNode()
    let cropNode = SKCropNode()
    var explosion = SKSpriteNode()
    
    
    enum GameState {
        case aiming, powering, shooting, dead
        init(){
            self = .aiming
        }
        mutating func next() {
            
            if self == .aiming{
                self = .powering
            } else if self == .powering {
                self = .shooting
            } else if self == .shooting{
                self = .aiming
            }
            else if self == .dead {
                self = .dead
            }
        }
    }
    
    @objc func buttonTap() {
        print("Button pressed")
        
        if numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                playernum[currentplayer].currentState.next()
            case .powering:
                fire(angle: Double(playernum[currentplayer].radians), vel: 5000, player: playernum[currentplayer])
                playernum[currentplayer].currentState.next()
            case .shooting:
                playernum[currentplayer].currentState.next()
                changePlayer()
            case .dead:
                playernum[currentplayer].currentState.next()
            }
        }
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
        static let tankpipe: UInt32 = 0x1 << 4
    }
    
    
    
    
    class player {
        
        
        let grids = true
        
        var radians : CGFloat = 0
        var power : CGFloat = 0
        var armor : CGFloat = 0
        
        var currentState = GameState()
        
        var menu = SKSpriteNode()
        var bullet = SKSpriteNode(imageNamed: "bullet")
        let arrow = SKSpriteNode(imageNamed: "arrow")
        
        var tank = SKSpriteNode(imageNamed: "tankbody")
        var tankpipe = SKSpriteNode(imageNamed: "tankpipe")
        
        var labelangle = SKLabelNode()
        var labelpower = SKLabelNode()
        var labelarmor = SKLabelNode()
        
        
        
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
            if body1.node?.name == "bullet" {
                spawnexplosion(ground: ground, spawnPosition: contact.contactPoint)
                body1.node?.removeFromParent()
                body1.node?.name = ""
                //explode(contactPoint: contact.contactPoint)
            }
            
        }
        
        if body2.categoryBitMask == pc.tank {
            if body1.node?.name == "bullet" {
                let number = Int((body2.node?.name)!)
                spawnexplosion(ground: ground, spawnPosition: contact.contactPoint)
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                body1.node?.name = ""
                playernum[number!].tankpipe.removeFromParent()
                playernum[number!].currentState = .dead
                numalive -= 1
                if numalive < 2 {
                    let newGame = GameScene(size: self.size)              // seitenverhältnis wird irgendwie geändert
                    let transition = SKTransition.crossFade(withDuration: 2)
                    self.view?.presentScene(newGame, transition: transition)
                }
                
                //explode(contactPoint: contact.contactPoint)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if numalive > 1 {
            switch playernum[currentplayer].currentState {
            case .aiming:
                //setArrow(player: playernum[currentplayer])
                for touch: AnyObject in touches {
                    fingerlocation = touch.location(in: self)
                }
            case .powering: break
            case .shooting: break
            case .dead: break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                for touch: AnyObject in touches {
                    fingerlocation = touch.location(in: self)
                }
            case .powering: break
            case .shooting: break
            case .dead: break
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                for touch: AnyObject in touches {
                    fingerlocation = touch.location(in: self)
                }
                playernum[currentplayer].radians = atan2(fingerlocation.y-playernum[currentplayer].tank.position.y, fingerlocation.x-playernum[currentplayer].tank.position.x)
                //playernum[currentplayer].arrow.zRotation = playernum[currentplayer].radians
            case .powering: break
            case .shooting:break
            case .dead: break
            }
        }
    }
    
    override func update (_ currentTime: CFTimeInterval) {
        if numalive > 1{
            switch playernum[currentplayer].currentState {
            case .aiming:
                playernum[currentplayer].radians = atan2(fingerlocation.y-playernum[currentplayer].tank.position.y, fingerlocation.x-playernum[currentplayer].tank.position.x)
                //playernum[currentplayer].arrow.zRotation = playernum[currentplayer].radians
                playernum[currentplayer].tankpipe.zRotation = playernum[currentplayer].radians
                
               
                    labelanzeige.text = "Spieler " + String(currentplayer + 1) + ": Ziele!"
               
            case .powering:
                labelanzeige.text = "Spieler " + String(currentplayer + 1) + ": Power?!"
            case .shooting:
                labelanzeige.text = "Boooom"
            case .dead:
                labelanzeige.text = "Dead?"
            }
        }
        print(playernum[currentplayer].currentState)
        print(currentplayer)
    }
    
    func setUpGame() {
        self.physicsWorld.contactDelegate = self
        ground = GroundNode(color: UIColor.green, size: CGSize(width: 1968, height: 1125))
        ground.position = CGPoint(x:  (CGSize(width: 1968, height: 300).width / 2), y: 1125 / 2)
        ground.setup()
        ground.zPosition = 3
        addChild(ground)
        
        c.grav = -6
        c.vel = 5000
        
        let buttonTexture: SKTexture! = SKTexture(imageNamed: "tank")
        let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "tankpipe")
        let button = FTButtonNode(normalTexture: buttonTexture, selectedTexture: buttonTextureSelected, disabledTexture: buttonTexture)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(GameScene.buttonTap))
        button.setButtonLabel(title: "Weiter", font: "Arial", fontSize: 80)
        button.position = CGPoint(x: self.frame.midX,y: self.frame.midY)
        button.zPosition = 4
        button.setScale(0.2)
        button.name = "button"
        self.addChild(button)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: c.grav)
        
        explosion = SKSpriteNode(imageNamed: "explosion")
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        for i in 0...nplayer-1 {
            playernum.append(player())
            
            playernum[i].tank.setScale(0.18)
            playernum[i].tank.name = String(i)
            playernum[i].tank.zPosition = 4
            playernum[i].tank.position = CGPoint(x: self.size.width / CGFloat(nplayer + 1) * CGFloat(i + 1), y: 600)
            playernum[i].tank.physicsBody = SKPhysicsBody(rectangleOf: playernum[i].tank.size)
            playernum[i].tank.physicsBody!.affectedByGravity = true
            playernum[i].tank.physicsBody!.categoryBitMask = pc.tank
            playernum[i].tank.physicsBody!.collisionBitMask = pc.ground
            playernum[i].tank.physicsBody!.contactTestBitMask = pc.bullet
            playernum[i].tank.physicsBody!.isDynamic = true
            playernum[i].tank.physicsBody!.friction = 1
            playernum[i].tank.physicsBody!.mass = 100

            playernum[i].tank.physicsBody!.restitution = 0

            self.addChild(playernum[i].tank)
            
            playernum[i].tankpipe.setScale(0.18)
            playernum[i].tankpipe.anchorPoint = CGPoint(x:0,y: 0.5)
            playernum[i].tankpipe.position = CGPoint(x: playernum[i].tank.position.x, y: playernum[i].tank.position.y+10)
            playernum[i].tankpipe.zPosition = 5
            let centerPoint = CGPoint(x:playernum[i].tankpipe.size.width / 2 - (playernum[i].tankpipe.size.width * playernum[i].tankpipe.anchorPoint.x), y:playernum[i].tankpipe.size.height / 2 - (playernum[i].tankpipe.size.height * playernum[i].tankpipe.anchorPoint.y))
            
            playernum[i].tankpipe.physicsBody = SKPhysicsBody(rectangleOf: playernum[i].tankpipe.size, center: centerPoint)
            playernum[i].tankpipe.physicsBody!.affectedByGravity = false
            playernum[i].tankpipe.physicsBody!.categoryBitMask = pc.tankpipe
            playernum[i].tankpipe.physicsBody!.collisionBitMask = pc.ground
            playernum[i].tankpipe.physicsBody!.isDynamic = true

            

            let joint = SKPhysicsJointPin.joint(withBodyA: playernum[i].tankpipe.physicsBody!, bodyB: playernum[i].tank.physicsBody!, anchor: CGPoint(x: playernum[i].tank.position.x, y: playernum[i].tank.position.y+10))
            self.addChild(playernum[i].tankpipe)
            physicsWorld.add(joint)
        }
        
       /* labelanzeige.text = "Rechter Spieler: Ziele!"
        labelanzeige.position = CGPoint(x: self.frame.width / 2, y: self.frame.height*0.8)
        labelanzeige.fontColor = SKColor.black
        labelanzeige.fontSize = 50
        self.addChild(labelanzeige)*/
        
        windlbl.text = "Wind = 0"
        windlbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height*0.8)
        windlbl.fontSize = self.frame.width/25
        windlbl.fontColor = SKColor.black
        windlbl.zPosition = background.zPosition + 1
        self.addChild(windlbl)
        setWind()
    }
    
    
    func fire(angle: Double, vel: Double, player: player){
        setBullet(player: player)
        self.addChild(player.bullet)
        //player.arrow.removeFromParent()
        let x = vel * cos(angle)
        let y = vel * sin(angle)
        let shotVec = CGVector(dx: x, dy: y)
        player.bullet.physicsBody?.applyImpulse(shotVec)
        let windvec = CGVector(dx: wind, dy: 0)
        let push = SKAction.applyForce(windvec, duration: 1)
        player.bullet.run(push)
    }
    
    
    
   /* func setArrow(player: player) {
        player.arrow.setScale(0.5)
        player.arrow.anchorPoint = CGPoint(x:0,y: 0.5)
        player.arrow.position = CGPoint(x: player.tank.position.x, y: player.tank.position.y)
        player.arrow.zPosition = 1
        self.addChild(player.arrow)
    }
    */
    /*func explode (contactPoint: CGPoint) {
     let explosion = SKSpriteNode (imageNamed: "explosion")
     explosion.setScale(0.1)
     explosion.position = contactPoint
     explosion.zPosition = 10
     addChild(explosion)
     let shockwave = SKShapeNode(circleOfRadius: 1)
     let shockWaveAction: SKAction = {
     let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
     SKAction.fadeOut(withDuration: 0.5)])
     
     let sequence = SKAction.sequence([growAndFadeAction,
     SKAction.removeFromParent()])
     
     return sequence
     }()
     explosion.addChild(shockwave)
     explosion.run(shockWaveAction)
     shockwave.removeFromParent()
     explosion.removeFromParent()
     }
     
     */
    
    func spawnexplosion (ground: GroundNode, spawnPosition: CGPoint) {
        let explosion = SKSpriteNode (imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition  = 10
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 0.5, duration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        
        let groundLocation = convert(spawnPosition, to: ground)
        ground.hitAt(point: groundLocation)
    }
    
    func setWind() {
        let rnd = Int.random(in: -10...10)
        let factor = 200
        windlbl.text = "Wind = \(rnd)"
        wind = rnd * factor
    }

    func setBullet(player: player) {
        //bullet.removeFromParent()
        player.bullet = SKSpriteNode(imageNamed: "bullet")
        player.bullet.name = "bullet"
        player.bullet.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "bullet"), size: player.bullet.size)
        player.bullet.position = CGPoint(x: player.tank.position.x, y: player.tank.position.y+100)
        player.bullet.setScale(0.03)
        player.bullet.zPosition = 3
        player.bullet.physicsBody?.categoryBitMask = pc.bullet
        player.bullet.physicsBody?.collisionBitMask = pc.none
        player.bullet.physicsBody?.contactTestBitMask = pc.ground
        player.bullet.physicsBody?.contactTestBitMask = pc.tank
        player.bullet.physicsBody?.affectedByGravity = true
        player.bullet.physicsBody?.isDynamic = true
    }
    
    func changePlayer() {
        if currentplayer >= nplayer - 1 {
            currentplayer = 0
        }
        else {
            currentplayer += 1
        }
        setWind()
    }
}



