//
//  Settings.swift
//  sudoku
//
//  Created by Gautam on 10/27/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import Foundation

struct Settings {
    
    var music: Bool = true
    var level: String = "EASY"
    
    func toString() -> String {
        return music.description + "," + level
    }
    
    mutating func set(settingsString str: String) {
        var fields = str.components(separatedBy: ",")
        
        music = Bool(fields[0])!
        level = fields[1]
    }
    
    func getLevel() -> Int {
        switch level {
        case "EASY":
            // Random no b/w 33-46
            return Int(arc4random_uniform(14) + 33);
        case "MEDIUM":
            // Random no b/w 47-53
            return Int(arc4random_uniform(7) + 47);
        case "HARD":
            // Random no b/w 54-55
            return Int(arc4random_uniform(2) + 54);
        default:
            return 35
        }
    }
}
