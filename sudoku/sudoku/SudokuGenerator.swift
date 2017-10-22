    //
    //  SudokuGenerator.swift
    //  sudoku
    //
    //  Created by Gautam on 10/18/17.
    //  Copyright © 2017 Gautam. All rights reserved.
    //

    import Foundation

    struct SudokuGenrator{

        public private(set) var board = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)

        /**
         * Driver method for nextBoard.
         *
         * @param difficulty the number of blank spaces to insert
         * @return board, a partially completed 9x9 Sudoku board
         */
        mutating func nextBoard(_ difficulty: Int) -> [[Int]] {
            board = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
            nextCell(parX: 0, parY: 0)
            makeHoles(theseHoles: difficulty)
            return board
        }

        /**
         * Recursive method that attempts to place every number in a cell.
         *
         * @param x x value of the current cell
         * @param y y value of the current cell
         * @return true if the board completed legally, false if this cell
         * has no legal solutions.
         */
        private mutating func nextCell(parX x: Int, parY y: Int) -> Bool {
            var nextX: Int
            var nextY: Int = y
            var toCheck: [Int] = [1,2,3,4,5,6,7,8,9]
        
            var tmp: Int
            var current: Int
            let top: Int = toCheck.count;
            
            for i in stride(from: top - 1 , to: 0, by: -1) {
                
                current = Int(arc4random_uniform(UInt32(i)))
                tmp = toCheck[current]
                toCheck[current] = toCheck[i]
                toCheck[i] = tmp
                
            }
            
            for aToCheck in toCheck {
                if (legalMove(parX: x, parY: y,current: aToCheck)) {
                    board[x][y] = aToCheck;
                    if (x == 8) {
                        if (y == 8){
                            return true;
                        }//We're done!  Yay!
                        else {
                            nextX = 0;
                            nextY = y + 1;
                        }
                    } else {
                        nextX = x + 1;
                    }
                    if (nextCell(parX: nextX, parY: nextY)){
                    return true;
                    }
                }
            }
            
            board[x][y] = 0;
            return false;
        }

        /**
         * Given a cell's coordinates and a possible number for that cell,
         * determine if that number can be inserted into said cell legally.
         *
         * @param x       x value of cell
         * @param y       y value of cell
         * @param current The value to check in said cell.
         * @return True if current is legal, false otherwise.
         */
        private func legalMove(parX x: Int, parY y: Int, current value: Int) -> Bool {
            for i in stride(from: 0, to: 9, by: 1) {
                if (value == board[x][i]) {
                return false;
                }
            }
            
            for i in stride(from: 0, to: 9, by: 1) {
                if (value == board[i][y]) {
                return false;
                }
            }
            
            var cornerX: Int = 0;
            var cornerY: Int = 0;
            if (x > 2){
            if (x > 5){
            cornerX = 6;
            }
            else{
            cornerX = 3;
            }
            }
            if (y > 2){
            if (y > 5){
            cornerY = 6;
            }
            else{
            cornerY = 3;
            }
            }
            
            for i in cornerX ..< min(10, cornerX + 3) {
                for j in cornerY ..< min(10, cornerY + 3) {
                  if (value == board[i][j]) {
                    return false;
                  }
                }
            }
            
            return true;
        }

        /**
         * Given a completed board, replace a given amount of cells with 0s
         * (to represent blanks)
         *
         * @param holesToMake How many 0s to put in the board.
         */
        private mutating func makeHoles(theseHoles holesToMake: Int) {
            /*  We define difficulty as follows:
             Easy: 32+ clues (49 or fewer holes)
             Medium: 27-31 clues (50-54 holes)
             Hard: 26 or fewer clues (54+ holes)
             This is human difficulty, not algorithmically (though there is some correlation)
             */
            var remainingSquares: Double = 81
            var remainingHoles: Double = Double(holesToMake)
            
            for i in 0..<9 {
            for j in 0..<9 {
                let holeChance: Double = remainingHoles / remainingSquares
                if (drand48() <= holeChance) {
                    board[i][j] = 0;
                    remainingHoles -= 1;
                }
                remainingSquares -= 1;
                }
            }
        }

        /**
         * Prints a representation of board on stdout
         */
        func printBoard() {
            for i in 0..<9  {
                for j in 0..<9 {
                print("\(board[i][j]) ")
                }
                print("\n")
            }
            print("\n")
        }

        func getThisElement(row x: Int, column y: Int) -> Int{
            return board[x][y];
        }
        
        mutating func setThisElement(row x: Int, column y: Int, value v: Int) {
            board[x][y] = v;
        }
        
    }


