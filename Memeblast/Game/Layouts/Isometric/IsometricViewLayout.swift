// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A layout class used to layout the grid in the game.
 Code inspired from https://www.raywenderlich.com/392-uicollectionview-custom-layout-tutorial-pinterest
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import UIKit

class IsometricViewLayout: GridLayout {
    override func prepare() {
        func addFrameToAttributeAndCache(frame: CGRect, indexPath: IndexPath) {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        }

        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        let numberOfColumns = Settings.numberOfColumns
        let numberOfRows = Settings.numberOfRow

        var sizeOfGameBubble: CGFloat {
            return contentWidth / CGFloat(numberOfColumns)
        }

        let columnWidth = sizeOfGameBubble
        var row: Double = 0

        // Build layout here //

        // Generate xCoordinate of even rows.
        var xOffsetEven: [CGFloat] = []
        for column in 0 ..< numberOfColumns - 1 {
            xOffsetEven.append(CGFloat(column) * columnWidth + 0.5 * columnWidth)
        }

        // Generate xCoordinate of odd rows.
        var xOffsetOdd: [CGFloat] = []
        for column in 0 ..< numberOfColumns {
            xOffsetOdd.append(CGFloat(column) * columnWidth)
        }

        // Function to get y_coordinate
        var yCoordinate: CGFloat {
            return CGFloat(sqrt(3) / 2 * row) * sizeOfGameBubble
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
            add(xCoordinates: xOffsetOdd, yCoordinate: yCoordinate)
            add(xCoordinates: xOffsetEven, yCoordinate: yCoordinate)
        }
    }
}
