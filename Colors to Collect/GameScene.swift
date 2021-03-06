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
    private let offBlackColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    internal let offWhiteColor = UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    internal let orangeColor = UIColor.orange
    internal let blueColor = UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    
    // Selector for the current color
    internal var colorSelection = 0
    
    // Location selected by the user
    internal var touchedLocation: CGPoint? = CGPoint()
    
    // Player sprite
    internal var player: SKSpriteNode? = SKSpriteNode()
    
    // Falling block
    internal var fallingBlock: SKSpriteNode? = SKSpriteNode()
    
    // Main Label that shows main text
    internal var mainLabel = SKLabelNode()
    
    // Score label
    internal var scoreLabel = SKLabelNode()
    
    // Player size definition. We can make this smaller to make the game more difficult
    private let playerSize = CGSize(width: 90, height: 90)
    
    // Falling Block size definition. We can make this larger to make the game more difficult
    private let fallingBlockSize = CGSize(width: 40, height: 40)
    
    // Speed at which the block falls. We can make this larger to make the game more difficult
    private let fallingBlockSpeed = 2.5
    
    // Spawn time for the falling block
    private let fallingBlockSpawnTime = 1.5
    
    // Speed at which the falling block rotates
    private let fallingBlockRotationSpeed = 1.0
    
    // Player Score
    internal var score = 0
    
    // Flag for if the game is over. Stops the app from responding to touch events
    internal var isGameOver = false
    
    // Game state. On launch, the label will default to the startup text and the state will be false, prompting the user to play. On start, the state will be true. On loss, the state returns to false and the game over screen is displayed.
    internal var isAlive = false
    
    // SpriteKit Physics Handling
    private struct physicsCategory {
        static let player: UInt32 = 1
        static let fallingBlock : UInt32 = 2
    }
    
    // Player starting position
    internal var playerStartingYPosition: CGFloat = 0
    
    // Screen Min
    internal var screenMin: CGFloat = 0
    
    // Screen Max
    internal var screenMax: CGFloat = 0
    
    /**
        Handler for when the scene is loaded
        Set the initial state
     */
    override func didMove(to view: SKView) {
        playerStartingYPosition = self.frame.minY + 250 + playerSize.height
        self.backgroundColor = offBlackColor
        physicsWorld.contactDelegate = self
        
        isGameOver = false
        isAlive = false
        score = 0
        
        spawnMainLabel()
        spawnScoreLabel()
        spawnPlayer()
    }
    
    /**
        Called when the user touches the screen
        Move to the X coordinate of the touch
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            return
        }
        
        if !isAlive {
            //Start the game
            isAlive = true
            mainLabel.run(SKAction.removeFromParent())
            setFallingBlockTimer()
        }
        
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
        if isGameOver {
            return
        }
        
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
        self.screenMin = self.frame.minX
        self.screenMax = self.frame.maxX
        self.setPlayerYPosition()
    }
    
    /**
        Generates the main label for the game and adds it to the scene
     */
    func spawnMainLabel() {
        spawnLabel(title: NSLocalizedString("start", comment: "Start!"))
    }
    
    /**
        Generates the game over label
     */
    func spawnGameOverLabel() {
        spawnLabel(title: NSLocalizedString("game_over", comment: "Game Over"))
    }
    
    /**
        Generates a label and adds it to the scene
     */
    func spawnLabel(title: String) {
        mainLabel = SKLabelNode(fontNamed: "Futura")
        mainLabel.fontSize = 100
        mainLabel.fontColor = offWhiteColor
        mainLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 250)
        mainLabel.text = title
        
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
        
        player?.position = CGPoint(x: self.frame.midX, y: playerStartingYPosition)
        
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
        let randomX = Int.random(in: Int(screenMin + 16)..<Int(screenMax - 16))
        let colorOfBlock = Int.random(in: 0...2)
        
        fallingBlock = SKSpriteNode(color: offWhiteColor, size: fallingBlockSize)
        fallingBlock?.position = CGPoint(x: randomX, y: Int(self.frame.maxY))
        fallingBlock?.physicsBody = SKPhysicsBody(rectangleOf: fallingBlock!.size)
        fallingBlock?.physicsBody?.affectedByGravity = false
        fallingBlock?.physicsBody?.allowsRotation = false
        fallingBlock?.physicsBody?.categoryBitMask = physicsCategory.fallingBlock
        fallingBlock?.physicsBody?.contactTestBitMask = physicsCategory.player
        fallingBlock?.physicsBody?.isDynamic = true
        fallingBlock?.name = "fallingBlockName"
        
        // Set color of block depending on random value
        switch colorOfBlock {
            case 1:
                fallingBlock?.color = orangeColor
                fallingBlock?.name = "fallingBlock1"
            case 2:
                fallingBlock?.color = blueColor
                fallingBlock?.name = "fallingBlock2"
            default:
                fallingBlock?.color = offWhiteColor
                fallingBlock?.name = "fallingBlock0"
        }
        
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
        let rotateAnimation = SKAction.rotate(byAngle: 2, duration: fallingBlockRotationSpeed)
        
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
            player?.position.x = self.frame.minX
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
            if self.isAlive {
                self.spawnFallingBlock()
            }
        }
        
        let sequence = SKAction.sequence([wait, spawn])
    
        self.run(SKAction.repeatForever(sequence))
    }
    
    /**
        Reset's the y position to the starting Y position
     */
    func setPlayerYPosition() {
        player?.position.y = playerStartingYPosition
    }
}

/**
    Phsyics delegate extension to handle block contact
 */
extension GameScene: SKPhysicsContactDelegate {
    /**
        Handles contact between two objects
     */
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        // If the two colliding objects are the same type, then ignore the collision
        guard firstBody.categoryBitMask != secondBody.categoryBitMask else {
            return
        }
        
        // Figure out which body is the player
        if (firstBody.categoryBitMask == physicsCategory.player) {
            handlePlayerBlockCollision(firstBody.node as! SKSpriteNode, secondBody.node as! SKSpriteNode)
        } else {
            handlePlayerBlockCollision(secondBody.node as! SKSpriteNode, firstBody.node as! SKSpriteNode)
        }
    }
    
    /**
        Handler for player and falling block collision
     */
    func handlePlayerBlockCollision(_ player: SKSpriteNode, _ block: SKSpriteNode) {
        //Ensure we are handling the correct contact
        guard player.name == "playerName" else {
            return
        }
        
        if (colorSelection == 0 && block.name == "fallingBlock0") {
            score += 1
            block.removeFromParent()
            updateScore()
        } else if (colorSelection == 1 && block.name == "fallingBlock1") {
            score += 1
            block.removeFromParent()
            updateScore()
        } else if (colorSelection == 2 && block.name == "fallingBlock2") {
            score += 1
            block.removeFromParent()
            updateScore()
        } else {
            player.removeFromParent()
            gameOver()
        }
    }
    
    /**
        Updates the score label
     */
    func updateScore() {
        scoreLabel.text = "\(NSLocalizedString("score", comment: "Score: "))\(score)"
    }
    
    /**
        Signals the game over and shows the user the final score
     */
    func gameOver() {
        isGameOver = true
        isAlive = false
        spawnGameOverLabel()
        restartGame()
    }
    
    /**
        Signals the system to restart the game after 3 seconds
     */
    func restartGame() {
        let wait = SKAction.wait(forDuration: 3.0)
        let startGame = GameScene(fileNamed: "GameScene")
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        startGame?.scaleMode = SKSceneScaleMode.aspectFill
        
        let changeScene = SKAction.run {
            self.view?.presentScene(startGame!, transition: transition)
        }
        
        let sequence = SKAction.sequence([wait, changeScene])
        self.run(SKAction.repeat(sequence, count: 1))
    }
}
