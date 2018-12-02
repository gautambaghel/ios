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
    private var settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = UserDefaults.standard
        let continueGameKey = "continueGame"
        let settingsKey = "settings"
        
        if let gameData = preferences.string(forKey: continueGameKey) {
            continueGame(Data: gameData)
        } else {
            startNewGame()
        }
        
        if let settings = preferences.string(forKey: settingsKey) {
            self.settings.set(settingsString: settings)
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        saveGame()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuController:MenuController = storyBoard.instantiateViewController(withIdentifier: "MenuController") as! MenuController
        self.present(menuController, animated: true, completion: nil)
    }
    
    @IBAction func tileTapped(_ sender: UITextField) {
    
        if let thisValue = Int(sender.text!),
           let loc = sender.accessibilityIdentifier,
           let thisRow = Int(loc.split(separator: ",")[0]),
           let thisColumn = Int(loc.split(separator: ",")[1]) {
            board.setThisElement(row: thisRow, column: thisColumn, value: thisValue)
            saveGame()
        }
        sender.endEditing(true)
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        
        board.printBoard()
        saveGame()
        
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
            // Delete saved data
            self.deleteGame()
            self.segueToCongratsController(msg: message)
        } else {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func segueToCongratsController(msg: String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let congratsController:CongratsController = storyBoard.instantiateViewController(withIdentifier: "CongratsController") as! CongratsController
        congratsController.message = msg
        self.present(congratsController, animated: true, completion: nil)
    }
  
    @IBAction func retry(_ sender: UIBarButtonItem) {
        let refreshAlert = UIAlertController(title: "Resetting Board", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yeah!", style: .default, handler: { (action: UIAlertAction!) in
            self.startNewGame()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    func startNewGame(){
        
        self.deleteGame()
        _ = board.nextBoard(settings.getLevel())
        board.printBoard()
        
        for (_, tile) in tiles.enumerated() {
          if let location = tile.accessibilityIdentifier {

            let thisRow = Int(location.split(separator: ",")[0])!
            let thisColumn = Int(location.split(separator: ",")[1])!
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
    }
    
    
    func continueGame(Data gameData: String){
        board.putState(Data: gameData)
        
        for (_, tile) in tiles.enumerated() {
        
          if let location = tile.accessibilityIdentifier,
             let thisRow = Int(location.split(separator: ",")[0]),
             let thisColumn = Int(location.split(separator: ",")[1]){
            
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
    
    func deleteGame(){
        let preferences = UserDefaults.standard
        let continueGameKey = "continueGame"
        
        preferences.set(nil, forKey: continueGameKey)
        //  Save to disk
        preferences.synchronize()
    }
    
}

