//
//  FastPowerScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation


class FastPowerScoreFunction: FastScoreFunction{
    
    let exponent: Double
    
    init(exponent: Double) {
        self.exponent = exponent
        super.init()
    }
    
    override func rowScore(row: Int, entries: [Double]) -> Double {
        return entries.map{$0 * $0}.reduce(0.0, +) 
    }
    
}
