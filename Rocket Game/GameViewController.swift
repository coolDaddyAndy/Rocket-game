//
//  GameViewController.swift
//  Rocket Game
//
//  Created by Andrey Sushkov on 5.11.21.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "backingAudio", ofType: "mp3")
        let audioURL = NSURL(fileURLWithPath: filePath!)
        
        do {
            backingAudio = try AVAudioPlayer(contentsOf: audioURL as URL)
        }
        catch {
            return print ("Cannot find the audio")
        }

        backingAudio.volume = 1
        backingAudio.numberOfLoops = -1
        backingAudio.play()
       
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
