// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A table view cell to show name of level. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit

class LevelSelectionTableViewCell: UITableViewCell {

    @IBOutlet private var levelName: UILabel!

    func setLevelName(name: String) {
        levelName.text = name
    }
}
