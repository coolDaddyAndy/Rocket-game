//
//  GameOverScene.swift
//  Rocket Game
//
//  Created by Andrey Sushkov on 7.11.21.
//

import Foundation
import SpriteKit


class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Конец игры!"
        gameOverLabel.fontSize = 140
        gameOverLabel.fontColor = .systemRed
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scorelabel = SKLabelNode(fontNamed: "The Bold Font")
        scorelabel.text = "Сбито: \(gameScore)"
        scorelabel.fontSize = 80
        scorelabel.fontColor = .systemYellow
        scorelabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.55)
        scorelabel.zPosition = 1
        self.addChild(scorelabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLabel.text = "Лучший результат: \(highScoreNumber)"
        highScoreLabel.fontSize = 80
        if #available(iOS 15.0, *) {
            highScoreLabel.fontColor = .systemMint
        } else {
            highScoreLabel.fontColor = .systemOrange
        }
        highScoreLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
      
        restartLabel.text = "Играть еще"
        restartLabel.fontSize = 80
        restartLabel.fontColor = .systemYellow
        restartLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.25)
        self.addChild(restartLabel)
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch) {
            
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(sceneToMoveTo, transition: transition)
                
            }
        }
    }
    
}
