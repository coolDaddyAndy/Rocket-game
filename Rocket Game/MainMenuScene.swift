//
//  MainMenuScene.swift
//  Rocket Game
//
//  Created by Andrey Sushkov on 9.11.21.
//
import Foundation
import SpriteKit


class MainMenuScene: SKScene {
    
    let startGame = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        
        startGame.text = "Новая игра"
        startGame.fontSize = 130
        startGame.fontColor = .systemYellow
        startGame.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        startGame.zPosition = 1
        startGame.name = "StartGameButton"
        self.addChild(startGame)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            if startGame.contains(pointOfTouch) {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(sceneToMoveTo, transition: transition)
            }
        }
    }
}
