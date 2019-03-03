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
    func presentAlert(title: String, message: String, image: UIImage?) {
        let popup = PopupDialog(title: title, message: message, image: image)
        let restartButton = DefaultButton(title: "Restart game", height: 60) {
            [weak self]() in
            self?.gameDelegate?.restartLevel()
        }

        let cancelButton = CancelButton(title: "CANCEL") {
        }

        popup.addButtons([restartButton, cancelButton])
        // Present dialog
        gameDelegate?.present(popup, animated: true)
    }

    func unsavedGameAlert() {
        // Prepare the popup assets
        let title = "Game not saved"
        let message = "Your score is not recorded as you did not save this level yet."
        presentAlert(title: title, message: message, image: nil)
    }

    func newHighscoreAlert() {
        guard let gameDelegate = gameDelegate else {
            return
        }
        // Prepare the popup assets
        let title = "New high score!"
        let message = "You have set a new high score of \(gameDelegate.score)"
        let image = UIImage(named: Constants.trophyImage)
        presentAlert(title: title, message: message, image: image)
    }

    func didntBreakHighscoreAlert() {
        guard let gameDelegate = gameDelegate else {
            return
        }
        // Prepare the popup assets
        let title = "Game Over"
        let message = "Your score of \(gameDelegate.score ) did not break the high " +
        "score of \(gameDelegate.currentLevel.highscore)!"
        let image = UIImage(named: Constants.didntBreakHighscore)
        presentAlert(title: title, message: message, image: image)
    }
}
