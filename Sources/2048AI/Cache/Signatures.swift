//
//  Signatures.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

protocol Signable {
    func getSignature() -> String
}

extension Game: Signable {
    func getSignature() -> String {
        var str = "("
        for (piece, probability) in self.startingProbabilities {
            str += String(piece) + "_" + String(probability) + "_"
        }
        str += ")"
        return str
    }
}


extension FastWeightedScoreFunction: Signable {
    func getSignature() -> String {
        var str = "(FastWeighted_"
        for r in 0..<weights.count{
            for c in 0..<weights[0].count{
                str += String(weights[r][c]) + "_"
            }
        }
        str += ")"
        return str
    }
}

extension FastPowerScoreFunction: Signable {
     func getSignature() -> String {
        return "(FastPower\(self.exponent)"
    }
}
