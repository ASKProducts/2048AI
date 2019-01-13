//
//  DynamicDepthEMPlayer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/2/19.
//  Copyright © 2019 Aaron Kaufer. All rights reserved.
//

import Foundation

typealias ParameterChoosingFunction = (Game) -> (maxDepth: Int, samplingAmount: Int)

class DynamicDepthEMPlayer : ExpectimaxPlayer {
    
    let chooser: ParameterChoosingFunction
    
    init(chooser: @escaping ParameterChoosingFunction, useCache: Bool = false){
        self.chooser = chooser
        super.init(maxDepth: 1, samplingAmount: 1, useCache: useCache)
    }
    
    override func decide(game: Game) -> Move {
        
        let (maxDepth, samplingAmount) = chooser(game)
        self.maxDepth = maxDepth
        self.samplingAmount = samplingAmount
        return super.decide(game: game)
        
    }
    
}
