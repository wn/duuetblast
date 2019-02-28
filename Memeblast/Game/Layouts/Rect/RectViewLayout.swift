//
//  RectViewLayout.swift
//  Memeblast
//
//  Created by Ang Wei Neng on 24/2/19.
//  Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
//

import UIKit

class RectViewLayout: GridLayout {
    override func prepare() {
        func addFrameToAttributeAndCache(frame: CGRect, indexPath: IndexPath) {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        }

        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        let numberOfColumns = Constants.numOfCols
        let numberOfRows = Constants.numOfRows

        var sizeOfGameBubble: CGFloat {
            return contentWidth / CGFloat(numberOfColumns)
        }

        let columnWidth = sizeOfGameBubble
        var row: Double = 0

        // Build layout here //

        var xOffset: [CGFloat] = []
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }

        // Function to get y_coordinate
        var yCoordinate: CGFloat {
            return CGFloat(row) * sizeOfGameBubble
        }

        var numberOfBubbleCreated = 0
        let numberOfBubblesToCreate = collectionView.numberOfItems(inSection: 0)

        func add(xCoordinates: [CGFloat], yCoordinate: CGFloat) {
            // Check if we overflowed the screen
            guard Int(row) < numberOfRows else {
                return
            }
            for xCoordinate in xCoordinates {
                let indexPath = IndexPath(item: numberOfBubbleCreated, section: 0)
                let frame = CGRect(x: xCoordinate, y: yCoordinate, width: sizeOfGameBubble, height: sizeOfGameBubble)
                addFrameToAttributeAndCache(frame: frame, indexPath: indexPath)
                numberOfBubbleCreated += 1
            }
            row += 1
        }

        while numberOfBubbleCreated < numberOfBubblesToCreate {
            // Generate two rows, one with 12 bubbles, one with 11.
            add(xCoordinates: xOffset, yCoordinate: yCoordinate)
        }

    }

}
