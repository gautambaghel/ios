//
//  ViewController.swift
//  sudoku
//
//  Created by Gautam on 10/16/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
       var board = SudokuGenrator();
       print("\(board.nextBoard(35))") 
        
    }
}

