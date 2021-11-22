//
//  GameScene.swift
//  Rocket Game
//
//  Created by Andrey Sushkov on 5.11.21.
//

import SpriteKit

var gameScore = 0  // for visibility from other scenes in module

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
//    var livesNumber = 10
//    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound = SKAction.playSoundFileNamed("bulletSound.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosionSound.mp3", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    enum GameState {
        case preGame
        case inGame
        case afterGame
    }
    
    var currentGameState = GameState.preGame
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1  // 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    let gameArea: CGRect
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 19.5/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1 {
            
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
            
        }
        
        player.setScale(0.25)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Сбито: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = .systemYellow
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.25, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
//        livesLabel.text = "Lives: 10"
//        livesLabel.fontSize = 70
//        livesLabel.fontColor = SKColor.white
//        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
//        livesLabel.position = CGPoint(x: self.size.width * 0.75, y: self.size.height + livesLabel.frame.size.height)
//        livesLabel.zPosition = 100
//        self.addChild(livesLabel)
        
        let moveToScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveToScreenAction)
//        livesLabel.run(moveToScreenAction)
        
        tapToStartLabel.text = "Хочу играть!"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = .systemYellow
        tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeAction)
    }
    
    
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background") { background, stop in
            if self.currentGameState == .inGame {
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
    
    
    
    func startGame() {
        currentGameState = .inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.15, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
        
        
    }
    
    
//    func loseLife() {
//        livesNumber -= 1
//        livesLabel.text = "Lives: \(livesNumber)"
//
//        let scaleUP = SKAction.scale(to: 1.5, duration: 0.2)
//        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
//        let scaleSequence = SKAction.sequence([scaleUP, scaleDown])
//        livesLabel.run(scaleSequence)
//
//        if livesNumber == 0 {
//            runGameOver()
//        }
//    }
    
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Сбито: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 || gameScore == 75 || gameScore == 100 {
            startNewLevel()
        }
    }
    
    func runGameOver() {
        currentGameState = .afterGame
        
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet") { bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy") { enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run (changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 0.5)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
        
    }
    
    
    func changeScene() {
        let scenetoMoveTo = GameOverScene(size: self.size)
        scenetoMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(scenetoMoveTo, transition: myTransition)
        
        
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
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
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            // if the player has hit the enemy
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y ?? CGFloat(0)) < self.size.height {
            // if the bullet has hit the enemy
            
            addScore()
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    
    func startNewLevel() {
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber{
        case 1: levelDuration = 3
        case 2: levelDuration = 2.5
        case 3: levelDuration = 2
        case 4: levelDuration = 1
        case 5: levelDuration = 0.3
        default: levelDuration = 0.5
            print ("Cannot find level info")
        }
        
        
        let spawn = SKAction.run(spawnEnemy)
        let waitForSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitForSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy() {
        let randonXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnds = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randonXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnds, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 10)
        let deleteEnemy = SKAction.removeFromParent()
//        let loseLifeAction = SKAction.run(loseLife)
//        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLifeAction])
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        if currentGameState == .inGame {
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == .preGame {
            startGame()
        }
        
        else if currentGameState == .inGame {
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let previousPontOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPontOfTouch.x
            
            if currentGameState == .inGame {
                player.position.x += amountDragged
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
    
}


