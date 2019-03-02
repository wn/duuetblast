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
    

    func setLevelName(name: String?) {
        levelName.text = name
    }

    func setImage(_ data: Data?) {
        guard let data = data else {
            return
        }
        screenshot.image = UIImage(data:data, scale:1.0)
    }

    func setHighScore(_ score: Int) {
        if score == 0 {
            highscore.text = "-"
        } else {
            highscore.text = "\(score)"
        }
    }
}
