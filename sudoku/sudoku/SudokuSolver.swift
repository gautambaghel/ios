//
//  SudokuGenerator.swift
//  sudoku
//
//  Created by Gautam on 10/16/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import Foundation


struct SudokuSolver {
    
    
    // ***** Instance Variables *****
    private var puzzle: [[Int]]
    private var digits: [Bool]
    
    /**
     *check to be sure there is an entry 1-9 in each position in the matrix
     *exit with false as soon as you find one that is not
     *@return true if the board has correct entries, false otherwise
     */
    mutating func completed() -> Bool {
        
        for i in 0..<9 {
            for j in 0..<9 {
                if(puzzle[i][j] > 9 || puzzle[i][j] < 1){
                    return false;
                }
            }
        }
        return true;
    }
    
    mutating func checkPuzzle() -> Bool {
    // use checkRow to check each row
    for i in 0..<9 {
        if(!checkRow(thisRow: i)) {
                return false;
        }
    }
    
    // use checkColumn to check each column
    
    for i in 0..<9 {
        if(!checkColumn(thisColumn: i)) {
                return false;
        }
    }
    
    // use checkSquare to check each of the 9 blocks
        for i in stride(from: 0, to: 9, by: 3) {
            for j in stride(from: 0, to: 9, by: 3) {
                if(!checkSquare(thisRow: i, thisColumn: j)){
                    return false;
                }
            }
        }
        return true;
    }
    
    /**
     *Ensures that row r is legal
     *@param r the row to check
     *@return  true if legal, false otherwise.
     */
    private mutating func checkRow(thisRow r: Int ) -> Bool {
        resetCheck();
        for c in 0..<9{
            if( !digitCheck( thisDigit: puzzle[r][c] ) ){
                return false;
            }
        }
        return true;
        }
    
    /**
     *Ensures that column c is legal
     *@param c the column to check
     *@return  true if legal, false otherwise.
     */
    private mutating func checkColumn( thisColumn c: Int ) -> Bool {
        resetCheck();
        for r in 0..<9 {
            if( !digitCheck( thisDigit: puzzle[r][c] ) ){
                return false;
            }
        }
        return true;
        }
    /**
     *Ensures that a given square is legal
     *@param row    the initial row of the square
     *@param column the intial column of the square
     *@return       true if legal, false otherwise.
     */
    private mutating func checkSquare(thisRow row: Int, thisColumn column: Int) -> Bool {
        resetCheck();
        for r in 0..<3 {
            for c in 0..<3 {
                if( !digitCheck( thisDigit: puzzle[r + row][c + column] ) ){
                    return false;
                }
              }
            }
            return true;
        }
    
    /**
     *Keeps track of numbers used during a row/column/square check
     *@param n the number currently being checked
     *@return  true if the number has not been used yet, false otherwise
     */
        
    private mutating func digitCheck(thisDigit n: Int) -> Bool {
            if( n != 0 && digits[n] ){
                return false;
            }
            else{
                digits[n] = true;
                return true;
            }
        }
    
    /**
     *Resets digits to false
     */
    private mutating func resetCheck() {
        digits.removeAll();
    }
    
}
