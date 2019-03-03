//
//  GameEngine+Alerts.swift
//  Duuetblast
//
//  Created by Ang Wei Neng on 3/3/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import PopupDialog

extension GameEngine {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart Game", style: .default) { _ in
            self.gameDelegate?.restartLevel()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        gameDelegate?.present(alert, animated: true)
    }

    func unsavedGameAlert() {
        // Prepare the popup assets
        let title = "Game not saved"
        let message = "Your score is not recorded as you did not save this level yet."
        presentAlert(title: title, message: message)
    }

    func newHighscoreAlert() {
        guard let gameDelegate = gameDelegate else {
            return
        }
        // Prepare the popup assets
        let title = "New high score!"
        let message = "You have set a new high score of \(gameDelegate.score)"
        presentAlert(title: title, message: message)
    }

    func didntBreakHighscoreAlert() {
        guard let gameDelegate = gameDelegate else {
            return
        }
        // Prepare the popup assets
        let title = "Game Over"
        let message = "Your score of \(gameDelegate.score ) did not break the high " +
        "score of \(gameDelegate.currentLevel.highscore)!"
        presentAlert(title: title, message: message)
    }
}
