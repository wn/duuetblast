//
//  GridLayout.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 24/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

protocol GridLayoutDelegate: class {
    func getHeightOfGameArea() -> CGFloat
}


class GridLayout: UICollectionViewLayout {
    weak var delegate: GridLayoutDelegate!

    var cache = [UICollectionViewLayoutAttributes]()

    var contentHeight: CGFloat = 0

    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        // SHOULD NOT BE CALLED
        fatalError("Superclass should be called instead!")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
