//
//  CalculatorBrain.swift
//  stanford
//
//  Created by Gautam on 8/10/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    var resultIsPending: Bool = false
    private var description: String?? = ""
    private var storedDescription: String?? = ""
    private var M: String?
    
    private enum Operation{
        case constant(Double)
        case unaryOperation(((Double) -> Double))
        case binaryOperation(((Double, Double) -> Double))
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "e"   : Operation.constant(M_E),
        "π"   : Operation.constant(Double.pi),
        "log" : Operation.unaryOperation(log),
        "√"   : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "±"   : Operation.unaryOperation({-$0}),
        "✖️"  : Operation.binaryOperation(*),
        "➗"  : Operation.binaryOperation(/),
        "➕"  : Operation.binaryOperation(+),
        "➖"  : Operation.binaryOperation(-),
        "="   : Operation.equals
    ]
    
    mutating func performOpetation(_ symbol: String){
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                if resultIsPending{
                    description = description!! + symbol
                }else{
                    description = symbol
                }
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending{
                        description = storedDescription!! + symbol + "(" + String(describing: accumulator!) + ")"
                    }else{
                        description = symbol + "(" + description!! + ")"
                    }
                    accumulator = function(accumulator!)
                }
                
            case .binaryOperation(let function):
                if accumulator != nil {
                    resultIsPending = true
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    description = description!! + symbol
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryoperation()
                resultIsPending = false
            }
        }
    }
    
    private mutating func performPendingBinaryoperation(){
        if pendingBinaryOperation != nil && accumulator != nil{
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        
        let function: ((Double, Double) -> Double)
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
        
        if resultIsPending{
            storedDescription = description
            description = description!! + String(describing: accumulator!)
        }else{
            description = String(describing: accumulator!)
        }
    }
    
    func setOperand(variable named: String){
        
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {
         
        return (1,true,"Hello")
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    func getM() -> String {
        return M!
    }
    
    mutating func resetCalculator(){
        pendingBinaryOperation = nil
        accumulator = nil
        description = ""
    }
    
    func getDescription() -> String? {
        if resultIsPending{
            return description!! + "..."
        }else{
            return description!! + "="
        }
    }
    
}
