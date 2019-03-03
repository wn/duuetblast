// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A LevelData class used to store core data objects for individual grid bubble. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation
import CoreData

class GridBubbleData: NSManagedObject {
    // init required to use NSManagedObject
    // Solution from https://stackoverflow.com/a/36074057
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(position: Int, bubbleTypeId: Int) {
        let context = AppDelegate.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "GridBubbleData", in: context) else {
            fatalError("Core data should contain entity 'GridBubbleData'!")
        }
        super.init(entity: entity, insertInto: context)
        self.position = Int16(position)
        self.bubbleTypeId = Int32(bubbleTypeId)
    }
}
