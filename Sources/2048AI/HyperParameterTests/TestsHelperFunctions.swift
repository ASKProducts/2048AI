//
//  TestsHelperFunctions.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/28/19.
//

import Foundation

func ave(arr: [Double]) -> Double{
    return arr.reduce(0.0, +) / Double(arr.count)
}

func run(in queue: DispatchQueue, group: DispatchGroup, f: @escaping () -> ()) {
    group.enter()
    queue.async {
        f()
        group.leave()
    }
}

func timeSince(_ start: DispatchTime) -> Double {
    let currentTime = DispatchTime.now()
    return Double(currentTime.uptimeNanoseconds - start.uptimeNanoseconds)/1_000_000_000
}

func time(_ f: () -> ()) -> Double {
    let start = DispatchTime.now()
    f()
    let end = DispatchTime.now()
    let timeTaken = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)/1_000_000_000
    return timeTaken
}
