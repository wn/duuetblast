// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A collection view cell to show name of level.
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit

class LevelSelectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet var screenshot: UIImageView!

    @IBOutlet var highscore: UILabel!
    @IBOutlet var levelName: UILabel!

    @IBOutlet var screenshotView: UIView!

    func setLevelName(name: String?) {
        levelName.text = name
    }

    func setImage(_ data: Data?) {
        guard let data = data else {
            return
        }
        guard let image = UIImage(data:data, scale:1.0) else {
            return
        }
        let ratio = image.size.width / image.size.height

        let height = screenshotView.frame.height
        let width = ratio * height
        let viewFrame = screenshotView.frame
        let newX = screenshotView.frame.origin.x + viewFrame.width - width
        let newY = screenshotView.frame.origin.y
        screenshot.layer.frame = CGRect(x: newX, y: newY, width: width, height: height)

        screenshot.layer.borderWidth = 1
        screenshot.layer.masksToBounds = false
        screenshot.layer.borderColor = UIColor.black.cgColor
        screenshot.layer.cornerRadius = screenshot.layer.frame.height/2
        screenshot.clipsToBounds = true

        screenshot.image = image
        print(width)
    }

    func setHighScore(_ score: Int) {
        if score == 0 {
            highscore.text = "-"
        } else {
            highscore.text = "\(score)"
        }
    }
}
