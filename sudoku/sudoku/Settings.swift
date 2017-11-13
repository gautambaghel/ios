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
}
