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
    
    private var board = SudokuGenrator()
    
        override func viewDidLoad() {
           super.viewDidLoad()
           startGame()
        }
        
        @IBAction func tileTapped(_ sender: UITextField) {
            print(sender.text!)
            sender.endEditing(true)
        }
        
        @IBAction func submit(_ sender: UIButton) {
            
            var title = "Incorrect!"
            var message = "try again!"
            
            let alert = UIAlertController(title: "You WON!", message: "puzzle solved!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            startGame()
        }
        
        @IBAction func retry(_ sender: UIButton) {
            startGame()
        }
        
        
        func startGame(){
            
            board.printBoard(board.nextBoard(35))
            
            for (index, tile) in tiles.enumerated() {
                
                let thisRow = index / 9
                let thisColumn = index % 9
                let element = board.getThisElement(row: thisRow, column: thisColumn)
                
                // center every alphabet
                tile.textAlignment = .center
                
                if element != 0 {
                    tile.borderStyle = UITextBorderStyle.line
                    tile.isUserInteractionEnabled = false
                    tile.text = String(element)
                } else {
                    tile.borderStyle = UITextBorderStyle.roundedRect
                    tile.isUserInteractionEnabled = true
                    tile.text = ""
                }
                
            }
        }
}

