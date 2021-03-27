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
    private var blueColor = UIColor.blue
    
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
    
    // Player Score
    private var score = 0
    
    // Game state. On launch, the label will default to the startup text and the state will be false, prompting the user to play. On start, the state will be true. On loss, the state returns to false and the game over screen is displayed.
    private var isAlive = true
    
    // SpriteKit Physics Handling
    private struct physicsCategory {
        static let player: UInt32 = 1
        static let fallingBlock : UInt32 = 2
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = offBlackColor
        
        spawnMainLabel()
        spawnScoreLabel()
        spawnPlayer()
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        touchedLocation = pos
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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
        let randomX = Int(arc4random_uniform(500) + 300)
        
        fallingBlock = SKSpriteNode(color: offWhiteColor, size: fallingBlockSize)
        fallingBlock?.position = CGPoint(x: randomX, y: 1000)
        fallingBlock?.physicsBody = SKPhysicsBody(rectangleOf: fallingBlock!.size)
        fallingBlock?.physicsBody?.affectedByGravity = false
        fallingBlock?.physicsBody?.allowsRotation = false
        fallingBlock?.physicsBody?.categoryBitMask = physicsCategory.fallingBlock
        fallingBlock?.physicsBody?.contactTestBitMask = physicsCategory.player
        fallingBlock?.physicsBody?.isDynamic = true
        fallingBlock?.name = "fallingBlockName"
        
        self.addChild(fallingBlock!)
    }
}
