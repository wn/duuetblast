//
//  StartGameController.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class StartGameController: UIViewController {
    @IBAction func selectLevel(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newVC =
            storyBoard.instantiateViewController(
                withIdentifier: "levelSelector")
                as! SelectLevelViewController
        renderChildController(newVC)
    }

    @IBAction func designLevel(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        let alert = UIAlertController(title: "Rectangular OR Isometric?", message: "FUCKING MODULE", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Rectangular", style: .default) { _ in
            levelDesignerController.isRectGrid = true
            self.renderChildController(levelDesignerController)
        })
        alert.addAction(UIAlertAction(title: "Isometric", style: .default) { _ in
            levelDesignerController.isRectGrid = false
            self.renderChildController(levelDesignerController)
        })
        self.present(alert, animated: true)
    }
}
