//
//  UIViewController+Render.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

extension UIViewController: UIViewControllerTransitioningDelegate {
    func renderChildController(_ child: UIViewController) {
        self.addChild(child)
        view.addSubview(child.view)

        child.view.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .transitionFlipFromLeft, animations: {
            child.view.alpha = 1
            //self.view.alpha = 0
        }) { (finished) in
            self.didMove(toParent: self)
        }
    }


    func derenderChildController(_ moveToParent: Bool = true) {
        view.removeFromSuperview()
        removeFromParent()
        guard moveToParent else {
            return
        }
        willMove(toParent: nil)
    }
}
