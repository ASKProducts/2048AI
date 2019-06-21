//
//  TestsHelperFunctions.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/28/19.
//

import Foundation

func arithmeticMean(_ arr: [Double]) -> Double{
    return arr.reduce(0.0, +) / Double(arr.count)
}

func geometricMean(_ arr: [Double]) -> Double {
    return pow(2, arithmeticMean(arr.map{log2($0)}))
}

func run(in queue: DispatchQueue?, group: DispatchGroup, f: @escaping () -> ()) {
    group.enter()
    if let queue = queue{
        queue.async {
            f()
            group.leave()
        }
    }
    else{
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

func timeAsString(duration: Double) -> String{
    let hours = Int(floor(duration/3600.0))
    let minutes = Int(floor(duration/60)) % 60
    let seconds = floor((duration - floor(duration/60)*60)*100)/100.0
    let durationString = String(format: "%02d:%02d:%04.1f", hours, minutes, seconds)
    return durationString
}
