//
//  StartGameController.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit
import TransitionButton

class StartGameController: CustomTransitionViewController {

    @IBOutlet private var selectLevel: TransitionButton!

    override func viewDidLoad() {
        Settings.loadBackground(view: view)

        selectLevel.backgroundColor = UIColor(rgb: 0x21CE9B)
        selectLevel.setTitle("LOAD LEVEL", for: .normal)
        selectLevel.cornerRadius = selectLevel.frame.height / 4
        selectLevel.spinnerColor = .white
        selectLevel.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    @IBAction private func buttonAction(_ button: TransitionButton) {
        button.startAnimation()
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newVC =
                storyBoard.instantiateViewController(
                    withIdentifier: "levelSelector")
                    as! SelectLevelViewController
            DispatchQueue.main.async(execute: { () -> Void in
                button.stopAnimation(animationStyle: .shake) {
                    self.renderChildController(newVC)
                }
            })
        }
    }

    @IBAction private func designLevel(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let levelDesignerController =
            storyBoard.instantiateViewController(
                withIdentifier: "levelDesigner")
                as! LevelDesignViewController
        let alert = UIAlertController(
            title: "Rectangular OR Isometric?",
            message: "Choose your preferred grid layout",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Rectangular", style: .default) { _ in
            levelDesignerController.isRectGrid = true
            self.renderChildController(levelDesignerController)
        })
        alert.addAction(UIAlertAction(title: "Isometric", style: .default) { _ in
            levelDesignerController.isRectGrid = false
            self.renderChildController(levelDesignerController)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}
