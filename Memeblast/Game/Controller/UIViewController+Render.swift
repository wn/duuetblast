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
        didMove(toParent: self)
        child.viewWillAppear(true)
    }


    func derenderChildController(_ moveToParent: Bool = true) {
        guard let parent = self.parent else {
            return
        }
        view.removeFromSuperview()
        removeFromParent()
        guard moveToParent else {
            return
        }
        willMove(toParent: nil)
        parent.viewWillAppear(true)
    }
}
