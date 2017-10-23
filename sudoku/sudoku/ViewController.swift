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
        
        // yellow backgorund view boards
        for board in smallBoards {
            board.layer.cornerRadius = 10;
            board.layer.masksToBounds = true;
        }
        
        
        let preferences = UserDefaults.standard
        let continueGameKey = "continueGame"
        
        if let gameData = preferences.string(forKey: continueGameKey) {
            continueGame(Data: gameData)
        }else {
            startNewGame()
        }
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
                self.startNewGame()
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
        
        let refreshAlert = UIAlertController(title: "Resetting Board!", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yeah!", style: .default, handler: { (action: UIAlertAction!) in
            self.startNewGame()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    func startNewGame(){
        
        board.nextBoard(35)
        board.printBoard()
        
        for (index, tile) in tiles.enumerated() {
            
            let thisRow = index / 9
            let thisColumn = index % 9
            let element = board.getThisElement(row: thisRow, column: thisColumn)
            
            // center every alphabet
            tile.textAlignment = .center
            
            if element != 0 {
                makeThisTileFixed(Tile: tile)
                tile.text = String(element)
                board.setThisElementState(row: thisRow, column: thisColumn, state: "FIXED")
                
            } else {
                makeThisTileVariable(Tile: tile)
                tile.text = ""
            }
        }
    }
    
    func continueGame(Data gameData: String){
        board.putState(Data: gameData)
        
        for (index, tile) in tiles.enumerated() {
            
            let thisRow = index / 9
            let thisColumn = index % 9
            let element = board.getThisElement(row: thisRow, column: thisColumn)
            let state = board.getThisElementState(row: thisRow, column: thisColumn)
            
            // center every alphabet
            tile.textAlignment = .center
            
            if state == "FIXED" {
                
                makeThisTileFixed(Tile: tile)
                tile.text = String(element)
                
            } else {
                
                makeThisTileVariable(Tile: tile)
                
                if element == 0 {
                    tile.text = ""
                } else {
                    tile.text = String(element)
                }
                
            }
        }
    }
    
    func makeThisTileFixed(Tile tile: UITextField){
        tile.borderStyle = UITextBorderStyle.line
        tile.isUserInteractionEnabled = false
        tile.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
    
    func makeThisTileVariable(Tile tile: UITextField){
        tile.borderStyle = UITextBorderStyle.roundedRect
        tile.isUserInteractionEnabled = true
        tile.backgroundColor = UIColor.lightText
    }
    
    func saveGame(){
        let preferences = UserDefaults.standard
        let continueGameKey = "continueGame"
        
        preferences.set(board.getState(), forKey: continueGameKey)
        //  Save to disk
        preferences.synchronize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveGame()
    }
    
}

