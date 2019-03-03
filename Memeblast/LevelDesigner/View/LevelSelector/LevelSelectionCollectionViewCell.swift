// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A collection view cell to show name of level.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit

class LevelSelectionCollectionViewCell: UICollectionViewCell {

    var delegate: CardCellDelegate?

    @IBOutlet var highscoreLabel: UILabel!

    @IBOutlet var screenshot: UIImageView!

    @IBOutlet var levelName: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dualCannon: UILabel!

    @IBOutlet var screenshotView: UIView!

    func setLevelName(name: String?, dualCannon: Bool, time: Int) {
        guard let lvlName = name else {
            return
        }
        levelName.text = "⭑ \(lvlName) ⭑"
        self.dualCannon.text = dualCannon ? "✌🏽 Player" : "👆🏽 Player"
        timeLabel.text = "⏳ \(time) ⌛️"
    }

    func setImage(_ data: Data?) {
        guard let data = data,
            let image = UIImage(data: data, scale: 1.0) else {
            return
        }

        screenshot.image = image
        let ratio = image.size.width / image.size.height

        let boardWidth = screenshot.frame.width
        let boardHeight = screenshot.frame.height

        let height: CGFloat = screenshotView.frame.height
        let width = ratio * height
        let newX = screenshot.frame.origin.x + boardWidth / 2 - width / 2
        let newY = screenshot.frame.origin.y + boardHeight / 2 - height / 2
        screenshot.frame = CGRect(x: newX, y: newY, width: width, height: height)

        screenshot.layer.borderWidth = 1
        screenshot.layer.masksToBounds = false
        screenshot.layer.borderColor = UIColor.black.cgColor
        screenshot.layer.cornerRadius = screenshot.layer.frame.width / 2
        screenshot.layer.backgroundColor = UIColor.white.cgColor
        screenshot.clipsToBounds = true
        screenshot.alpha = 1

        // THIS BLOODY LINE BELOW TOOK 8H TO DEBUG!
        screenshot.translatesAutoresizingMaskIntoConstraints = true
        screenshotView.translatesAutoresizingMaskIntoConstraints = true
        screenshot.image = image

    }

    @IBAction func deleteLevel(_ sender: UIButton) {
        guard let delegate = delegate else {
            return
        }
        delegate.deleteAtPosition(self)

    }

    func setHighScore(_ score: Int) {
        if score == 0 {
            highscoreLabel.text = "   🏆 -"
        } else {
            highscoreLabel.text = "   🏆 \(score)"
        }
    }
}


protocol CardCellDelegate {
    func deleteAtPosition(_ cell: LevelSelectionCollectionViewCell)
}
