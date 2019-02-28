//
//  UIViewController+Render.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

extension UIViewController {
    func renderChildController(_ child: UIViewController) {
        self.addChild(child)
        view.addSubview(child.view)
        didMove(toParent: self)
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
