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
    @IBOutlet var smallBoards: [UIView]!
    @IBOutlet weak var menuButton: UIButton!
    
    private var board = SudokuGenrator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for board in smallBoards {
            board.layer.cornerRadius = 10;
            board.layer.masksToBounds = true;
        }
        
        startGame()
    }
    
    @IBAction func tileTapped(_ sender: UITextField) {
        
        let thisValue = Int(sender.text!)
        let loc = tiles.index(of: sender)
        
        let thisRow = loc! / 9
        let thisColumn = loc! % 9
        
        board.setThisElement(row: thisRow, column: thisColumn, value: thisValue!)
        sender.endEditing(true)
    }
    
    @IBAction func submit(_ sender: UIButton) {
        
        var title = "Incorrect!"
        var message = "Try again"
        var won = false
        
        let digits = Array(repeating: false, count: 10)
        var ss = SudokuSolver(puzzle: board.board, digits: digits)
        
        if (!ss.completed()) {
            message = "Board is unfinished";
        }
        else if (!ss.checkPuzzle()) {
            message = "Try again";
        }
        else {
            title = "You WON!"
            message = "puzzle solved!";
            won = true
        }
        
        if(won){
            let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { (action: UIAlertAction!) in
                self.startGame()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (action: UIAlertAction!) in
                self.menuButton.sendActions(for: .touchUpInside)
            }))
            
            present(refreshAlert, animated: true, completion: nil)

        } else {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func retry(_ sender: UIButton) {
        
        let refreshAlert = UIAlertController(title: "Reset Board?", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.startGame()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)

    }
    
    
    func startGame(){
        
        board.nextBoard(35)
        board.printBoard()
        
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
                tile.backgroundColor = UIColor(white: 1, alpha: 0.5)
            } else {
                tile.borderStyle = UITextBorderStyle.roundedRect
                tile.isUserInteractionEnabled = true
                tile.text = ""
            }
            
        }
    }
}

