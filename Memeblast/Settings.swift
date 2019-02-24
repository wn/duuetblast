// Copyright © 2019 nus.cs3217.a0164178x. All rights reserved.
/**
 A settings class to store the settings of the game. 
 - Authors: Ang Wei Neng
 - Date: 27/1/19
 */

import Foundation

class Settings {

    private static var settingsFile = "GameSettings"
    private static var settingsPlist = getSettings(settingsFile)

    // Modified from PS1
    private static func getSettings(_ fileName: String) -> [String: Int] {
        // You do not need to modify this function.
        guard let path = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            return [:]
        }
        guard let dictionary = NSDictionary(contentsOfFile: path), let settings = dictionary as? [String: Int] else {
            return [:]
        }
        return settings
    }

    public static var numberOfRow: Int {
        guard let rows = settingsPlist["numberOfRows"] else {
        fatalError("GameSettings has not set numberOfColumns or numberOfRows!")
        }
        return rows
    }

    public static var numberOfColumns: Int {
        guard let cols = settingsPlist["numberOfColumns"] else {
            fatalError("GameSettings has not set numberOfColumns or numberOfRows!")
        }
        return cols
    }
}
