//
//  BlankSpaceScoreFunc.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/3/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

class BlankSpaceScoreFunction: ScoreFunction{
    override func calculateScore(of game: Game) -> Double {
        return Double(game.availableSpots.count)
    }
    
    override var description: String {
        return "{Blank Space}"
    }
}
