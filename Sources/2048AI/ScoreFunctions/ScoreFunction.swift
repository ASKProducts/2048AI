//
//  ScoreFunction.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/16/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class ScoreFunction: CustomStringConvertible{
    
    func calculateScore(of game: Game) -> Double {
        fatalError("calculateScore(of:) must be overridden")
    }
    
    var description: String {
        fatalError("description must be overridden")
    }
}
