//
//  GroundNode.swift
//  PanzerKrieg
//
//  Created by Christin Erbach on 12.12.18.
//  Copyright © 2018 Johannes Conradi. All rights reserved.
//
import SpriteKit
import UIKit

class GroundNode: SKSpriteNode {
    
    struct pc {
        static let none: UInt32 = 0x1 << 0
        static let bullet: UInt32 = 0x1 << 1
        static let ground: UInt32 = 0x1 << 2
        static let tank: UInt32 = 0x1 << 3
        static let tankpipe: UInt32 = 0x1 << 4
    }
    
    var currentImage: UIImage!
    
    func setup() {
        name = "ground"
        
        currentImage = drawGround(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = pc.ground
        physicsBody?.contactTestBitMask = pc.bullet
    }
    
    
    func drawGround(size: CGSize) -> UIImage {
        // 1
        let renderer = UIGraphicsImageRenderer(size: size)
        var currentX: CGFloat = 0
        let img = renderer.image { ctx in
            // 2
            //var color: UIColor
            
        /*switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            } */
           // color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.68, alpha: 1)
            while currentX < 1968 {
                let size = CGSize(width: 20, height: Int.random(in: 300...320))
                currentX += size.width
                let position = CGPoint(x: currentX, y: 1125)
                let rectangle = CGRect(x: position.x, y: position.y, width: size.width, height: -size.height)
                ctx.cgContext.addRect(rectangle)
            }
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        
        return img
    }
    
    func hitAt(point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            currentImage.draw(at: CGPoint(x: 0, y: 0))
            
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        
        configurePhysics()
    }

}
