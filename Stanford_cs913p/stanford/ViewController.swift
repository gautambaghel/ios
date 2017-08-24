//
//  ViewController.swift
//  stanford
//
//  Created by Gautam on 8/10/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var acButton: UIButton!
    @IBOutlet weak var pendingDisplay: UILabel!
    
    var userIsInMiddleOfTyping = false
    var dotAlreadyPresent = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInMiddleOfTyping{
            
            let currentTextInDisplay = display!.text!
            display!.text = currentTextInDisplay + digit
            
        } else{
            
            display!.text = digit
            userIsInMiddleOfTyping = true
        }
        
        acButton.setTitle("C", for: UIControlState.normal)
    }
    
    var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set{
            
            let str = String(newValue)
            let last2 = str.substring(from:str.index(str.endIndex, offsetBy: -2))
            
            if last2 == ".0"{
                display.text = String(Int(newValue))
            } else{
                display.text = String(newValue)
            }
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsInMiddleOfTyping{
            brain.setOperand(displayValue)
            userIsInMiddleOfTyping = false
            dotAlreadyPresent = false
        }
        
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOpetation(mathematicalSymbol)
        }
        
        if let result = brain.result{
            displayValue = result
        }
        
        if let description = brain.getDescription() {
            pendingDisplay!.text = description
        }
    }
    
    
    @IBAction func clearDisplay(_ sender: UIButton) {
        
        dotAlreadyPresent = false
        userIsInMiddleOfTyping = false
        display!.text = "0"
        pendingDisplay!.text = " "
        brain.resetCalculator()
        acButton.setTitle("AC", for: UIControlState.normal)
    }
    
    @IBAction func insertDot(_ sender: UIButton) {
        
        if !dotAlreadyPresent{
            
            if userIsInMiddleOfTyping {
                
                let currentTextInDisplay = display!.text!
                display!.text = currentTextInDisplay + "."
                dotAlreadyPresent = true
                
            } else{
                
                display!.text = "0."
                userIsInMiddleOfTyping = true
                dotAlreadyPresent = true
                
            }
        }
    }
}

