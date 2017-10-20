//
//  ViewController.swift
//  sudoku
//
//  Created by Gautam on 10/16/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tiles: [UITextField]!
    
    override func viewDidLoad() {
       var board = SudokuGenrator();
       board.printBoard(board.nextBoard(35))
        
        for (index, tile) in tiles.enumerated() {
            
            let thisRow = index / 9
            let thisColumn = index % 9
            
            tile.text = String(board.getThisElement(row: thisRow, column: thisColumn))
        }
        
    }
}

