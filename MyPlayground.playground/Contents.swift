//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


// If the word contains special characters, return them
func containsSpecialCharIn(Word w: String) -> Character? {
    let okayChars : Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890%$")
    for splChar in okayChars {
        if !w.contains(splChar) {
            return splChar
        }
    }
    return nil
}
