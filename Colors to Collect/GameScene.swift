//
//  GameScene.swift
//  Colors to Collect
//
//  Created by Adam Ure on 3/27/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    /**
        Colors used in the game
        - Off Black
        - Off White
        - Orange
        - Blue
     */
    private var offBlackColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    private var offWhiteColor = UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    private var orangeColor = UIColor.orange
    private var blueColor = UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    
    // Selector for the current color
    private var colorSelection = 0
    
    // Location selected by the user
    private var touchedLocation: CGPoint? = CGPoint()
    
    // Player sprite
    private var player: SKSpriteNode? = SKSpriteNode()
    
    // Falling block
    private var fallingBlock: SKSpriteNode? = SKSpriteNode()
    
    // Main Label that shows main text
    private var mainLabel = SKLabelNode()
    
    // Score label
    private var scoreLabel = SKLabelNode()
    
    // Player size definition. We can make this smaller to make the game more difficult
    private var playerSize = CGSize(width: 60, height: 60)
    
    // Falling Block size definition. We can make this larger to make the game more difficult
    private var fallingBlockSize = CGSize(width: 40, height: 40)
    
    // Speed at which the block falls. We can make this larger to make the game more difficult
    private var fallingBlockSpeed = 2.5
    
    // Spawn time for the falling block
    private var fallingBlockSpawnTime = 1.5
    
    // Speed at which the falling block rotates
    private var fallingBlockRotationSpeed = 1.0
    
    // Player Score
    private var score = 0
    
    // Game state. On launch, the label will default to the startup text and the state will be false, prompting the user to play. On start, the state will be true. On loss, the state returns to false and the game over screen is displayed.
    private var isAlive = true
    
    // SpriteKit Physics Handling
    private struct physicsCategory {
        static let player: UInt32 = 1
        static let fallingBlock : UInt32 = 2
    }
    
    /**
        Handler for when the scene is loaded
        Set the initial state
     */
    override func didMove(to view: SKView) {
        self.backgroundColor = offBlackColor
        
        spawnMainLabel()
        spawnScoreLabel()
        spawnPlayer()
        
        setFallingBlockTimer()
    }
    
    /**
        Called when the user touches the screen
        Move to the X coordinate of the touch
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchedLocation = t.location(in: self)
            
            if isAlive {
                player?.position.x = touchedLocation?.x ?? t.location(in: self).x
            } else {
                movePlayerOffScreen()
            }
        }
    }
    
    /**
        Called when the user slides their finger across the screen while maintaining their touch
        Move to the X coordinate of the touch
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchedLocation = t.location(in: self)
            
            if isAlive {
                player?.position.x = touchedLocation?.x ?? t.location(in: self).x
            } else {
                movePlayerOffScreen()
            }
        }
    }
    
    /**
        Called when the user lifts their finger
        Change the color of the user
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchedLocation = t.location(in: self)

            changePlayerColor()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    /**
        Generates the main label for the game and adds it to the scene
     */
    func spawnMainLabel() {
        mainLabel = SKLabelNode(fontNamed: "Futura")
        mainLabel.fontSize = 100
        mainLabel.fontColor = offWhiteColor
        mainLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 250)
        mainLabel.text = NSLocalizedString("start", comment: "Start!")
        
        self.addChild(mainLabel)
    }
    
    /**
        Generates the score label for the game and adds it to the scene
     */
    func spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Futura")
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = offWhiteColor
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 150)
        scoreLabel.text = "\(NSLocalizedString("score", comment: "Score: "))\(score)"
        
        self.addChild(scoreLabel)
    }
    
    /**
        Creates the player node and sets its phyiscs
     */
    func spawnPlayer() {
        player = SKSpriteNode(color: offWhiteColor, size: playerSize)
        player?.size = playerSize
        
        player?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 250 + playerSize.height)
        
        player?.physicsBody = SKPhysicsBody(rectangleOf: player!.size)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.fallingBlock
        player?.physicsBody?.isDynamic = true
        player?.name = "playerName"
        
        self.addChild(player!)
    }
    
    /**
        Creates the falling block and sets its physics
     */
    func spawnFallingBlock() {
        let randomX = Int.random(in: Int(self.frame.minX + 16)..<Int(self.frame.maxX - 16))
        
        fallingBlock = SKSpriteNode(color: offWhiteColor, size: fallingBlockSize)
        fallingBlock?.position = CGPoint(x: randomX, y: Int(self.frame.maxY))
        fallingBlock?.physicsBody = SKPhysicsBody(rectangleOf: fallingBlock!.size)
        fallingBlock?.physicsBody?.affectedByGravity = false
        fallingBlock?.physicsBody?.allowsRotation = false
        fallingBlock?.physicsBody?.categoryBitMask = physicsCategory.fallingBlock
        fallingBlock?.physicsBody?.contactTestBitMask = physicsCategory.player
        fallingBlock?.physicsBody?.isDynamic = true
        fallingBlock?.name = "fallingBlockName"
        
        startBlockFall()
        
        self.addChild(fallingBlock!)
    }
    
    /**
        Sends the block from the top to the bottom
        Rotates the block repeatedly
        Destroys the block on end
     */
    func startBlockFall() {
        let moveForward = SKAction.moveTo(y: self.frame.minY - 200, duration: fallingBlockSpeed)
        let rotateAnimation = SKAction.rotate(byAngle: 1, duration: fallingBlockRotationSpeed)
        
        let destroy = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([moveForward, destroy])
        fallingBlock?.run(SKAction.repeatForever(rotateAnimation))
        fallingBlock?.run(SKAction.repeatForever(sequence))
    }
    
    /**
        Moves the player off the screen
     */
    func movePlayerOffScreen() {
        if !isAlive {
            player?.position.x = -300
        }
    }
    
    /**
        Changes the color that the player can collect
     */
    func changePlayerColor() {
        colorSelection = colorSelection + 1
        
        switch colorSelection {
            case 3:
                player?.color = offWhiteColor
                colorSelection = 0
                break
            case 2:
                player?.color = blueColor
                break
            case 1:
                player?.color = orangeColor
                break
            default:
                player?.color = offWhiteColor
                break
        }
    }
    
    /**
        Sets a timer to send a falling block repeatedly
     */
    func setFallingBlockTimer() {
        let wait = SKAction.wait(forDuration: fallingBlockSpawnTime)
        let spawn = SKAction.run {
            self.spawnFallingBlock()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
    
        self.run(SKAction.repeatForever(sequence))
    }
}
