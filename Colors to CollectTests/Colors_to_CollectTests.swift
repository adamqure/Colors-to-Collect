//
//  Colors_to_CollectTests.swift
//  Colors to CollectTests
//
//  Created by Adam Ure on 3/27/21.
//

import XCTest
import SpriteKit
@testable import Colors_to_Collect

class Colors_to_CollectTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGameOver() {
        let gameScene = GameScene()
        gameScene.gameOver()
        assert(gameScene.isGameOver)
    }
    
    func testStartGame() {
        let gameScene = GameScene()
        gameScene.didMove(to: SKView())
        assert(gameScene.score == 0)
        assert(!gameScene.isGameOver)
        assert(!gameScene.isAlive)
    }
    
    func testTouchEventGameOver() {
        let gameScene = GameScene()
        gameScene.isGameOver = true
        gameScene.isAlive = false
        gameScene.touchesBegan(Set(), with: nil)
        assert(!gameScene.isAlive)
    }
    
    func testTouchEventNotAlive() {
        let gameScene = GameScene()
        gameScene.isGameOver = false
        gameScene.isAlive = false
        gameScene.touchesBegan(Set(), with: nil)
        assert(gameScene.isAlive)
    }
    
    func testMainLabel() {
        let gameScene = GameScene()
        gameScene.spawnMainLabel()
        assert(gameScene.mainLabel.text == NSLocalizedString("start", comment: "Start"))
    }
    
    func testGameOverLabel() {
        let gameScene = GameScene()
        gameScene.spawnGameOverLabel()
        assert(gameScene.mainLabel.text == NSLocalizedString("game_over", comment: "Game Over"))
    }
    
    func testCreateLabel() {
        let gameScene = GameScene()
        gameScene.spawnLabel(title: "Test")
        assert(gameScene.mainLabel.text == "Test")
    }
    
    func testCreateScoreLabel() {
        let gameScene = GameScene()
        gameScene.score = 9
        gameScene.spawnScoreLabel()
        assert(gameScene.scoreLabel.text == "\(NSLocalizedString("score", comment: "Score"))9")
    }
    
    func testCreatePlayer() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        assert(gameScene.player != nil)
        assert(gameScene.player?.physicsBody?.categoryBitMask == 1)
    }
    
    func testCreateFallingBlock() {
        let gameScene = GameScene()
        gameScene.screenMin = 0
        gameScene.screenMax = 50
        gameScene.spawnFallingBlock()
        assert(gameScene.fallingBlock != nil)
        assert(gameScene.fallingBlock?.physicsBody?.categoryBitMask == 2)
    }
    
    func testMovePlayerOffScreenIsAlive() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.player?.position.x = 50
        gameScene.isAlive = true
        gameScene.movePlayerOffScreen()
        assert(gameScene.player?.position.x == 50)
    }
    
    func testMovePlayerOffScreenNotAlive() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.player?.position.x = 50
        gameScene.isAlive = false
        gameScene.movePlayerOffScreen()
        assert(gameScene.player?.position.x != 50)
    }
    
    func testChangePlayerColor0() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.colorSelection = 0
        gameScene.changePlayerColor()
        
        assert(gameScene.colorSelection == 1)
        assert(gameScene.player?.color == gameScene.orangeColor)
    }
    
    func testChangePlayerColor1() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.colorSelection = 1
        gameScene.changePlayerColor()
        
        assert(gameScene.colorSelection == 2)
        assert(gameScene.player?.color == gameScene.blueColor)
    }
    
    func testChangePlayerColor2() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.colorSelection = 2
        gameScene.changePlayerColor()
        
        assert(gameScene.colorSelection == 0)
    }
    
    func testSetPlayerYPosition() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.playerStartingYPosition = 50
        gameScene.setPlayerYPosition()
        assert(gameScene.player?.position.y == 50)
    }

    func testHandlePlayerBlockPositionMatching() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.screenMin = 0
        gameScene.screenMax = 50
        gameScene.spawnFallingBlock()
        gameScene.score = 0
        gameScene.colorSelection = 1
        gameScene.fallingBlock?.name = "fallingBlock1"
        gameScene.handlePlayerBlockCollision(gameScene.player!, gameScene.fallingBlock!)
        assert(gameScene.score == 1)
    }
    
    func testHandlePlayerBlockPositionNotMatching() {
        let gameScene = GameScene()
        gameScene.spawnPlayer()
        gameScene.screenMin = 0
        gameScene.screenMax = 50
        gameScene.spawnFallingBlock()
        gameScene.isGameOver = false
        gameScene.isAlive = true
        gameScene.colorSelection = 0
        gameScene.fallingBlock?.name = "fallingBlock1"
        gameScene.handlePlayerBlockCollision(gameScene.player!, gameScene.fallingBlock!)
        assert(gameScene.isGameOver)
        assert(!gameScene.isAlive)
    }
    
    func testUpdateScore() {
        let gameScene = GameScene()
        gameScene.score = 0
        gameScene.spawnScoreLabel()
        assert(gameScene.scoreLabel.text == "\(NSLocalizedString("score", comment: "Score"))0")
        gameScene.score = 2
        gameScene.updateScore()
        assert(gameScene.scoreLabel.text == "\(NSLocalizedString("score", comment: "Score"))2")
    }
}
