//
//  Player.swift
//  schepens
//
//  Created by Gautam on 7/28/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

struct Player {
    var name: String?
    var game: String?
    var rating: Int
    
    init(name: String?, game: String?, rating: Int) {
        self.name = name
        self.game = game
        self.rating = rating
    }
}
