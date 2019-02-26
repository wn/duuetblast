// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A LevelData class used to store core data objects for each level. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation
import CoreData

class LevelData: NSManagedObject {
    // init required to use NSManagedObject
    // Solution from https://stackoverflow.com/a/36074057
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(name: String, isRect: Bool) {
        let context = AppDelegate.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "LevelData", in: context) else {
            fatalError("Core data must contain entity LevelData!")
        }
        super.init(entity: entity, insertInto: context)
        levelName = name
        self.isRectGrid = isRect
    }

    func saveBubbles(bubbles: [GridBubble]) {
        for bubble in bubbles {
            addToBubbles(bubble.savedBubbleData())
        }
    }

    public static func deleteLevel(name: String) -> Bool {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        var result: [Any] = []
        do {
            result = try context.fetch(request)
        } catch {
            return false
        }
        guard let levels = result as? [LevelData] else {
            return false
        }
        for level in levels {
            if let levelName = level.levelName, levelName == name {
                context.delete(level)
            }
        }

        do {
            try context.save()
        } catch {
            return false
        }
        return true
    }

    public static var namesOfSavedGames: [String] {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LevelData")
        request.returnsObjectsAsFaults = false
        var savedLevels: [String] = []
        do {
            let result = try context.fetch(request)
            guard let levels = result as? [LevelData] else {
                return []
            }
            for level in levels {
                guard let levelName = level.value(forKey: "levelName") as? String else {
                    return []
                }
                savedLevels.append(levelName)
            }
        } catch {
            print("Failed")
        }
        return savedLevels
    }
}
