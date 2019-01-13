//
//  BlankSpaceScoreFunc.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/3/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

func blankSpaceScoreFunc(game: Game) -> Double {
    return Double(game.availableSpots.count)
}
