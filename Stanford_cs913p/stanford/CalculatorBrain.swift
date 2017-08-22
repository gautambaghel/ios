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
    
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
    "e"   : Operation.constant(M_E),
    "log" : Operation.unaryOperation(log),
    "√"   : Operation.unaryOperation(sqrt),
    "cos" : Operation.unaryOperation(cos),
    "sin" : Operation.unaryOperation(sin),
    "tan" : Operation.unaryOperation(tan),
    "±"   : Operation.unaryOperation({-$0}),
    "x²"  : Operation.unaryOperation({$0 * $0}),
    "✖️"  : Operation.binaryOperation({$0 * $1}),
    "➗"  : Operation.binaryOperation({$0 / $1}),
    "➕"  : Operation.binaryOperation({$0 + $1}),
    "➖"  : Operation.binaryOperation({$0 - $1}),
    "="   : Operation.equals,
    ]
    
    mutating func performOpetation(_ symbol: String){
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
                
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryoperation()
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
    
    let function: (Double, Double) -> Double
    let firstOperand: Double
    
    func perform(with secondOperand: Double) -> Double{
              return function(firstOperand, secondOperand)
      }
    
    }
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    mutating func resetBrain(){
        pendingBinaryOperation = nil
        accumulator = nil
    }
    
}
