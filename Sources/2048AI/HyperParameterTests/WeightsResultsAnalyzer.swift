//
//  WeightsResultsAnalyzer.swift
//  2048AI
//
//  Created by Aaron Kaufer on 1/29/19.
//

import Foundation

extension String {
    func convertToDoubleArray() -> [Double]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Double]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

func analyzeWeightsResults(from str: String){
    var cleanStr = String(str.dropFirst().dropLast())
    cleanStr = cleanStr.replacingOccurrences(of: "], [", with: "]\n [")
    cleanStr = cleanStr.replacingOccurrences(of: "(", with: "[")
    cleanStr = cleanStr.replacingOccurrences(of: ")", with: "]")
    
    let lines = cleanStr.components(separatedBy: ["\n"])
    var results: [[Double]: [(Double, Double)]] = [:]
    for line in lines {
        let parts = line.components(separatedBy: [":"])
        let key: [Double] = parts[0].convertToDoubleArray()!
        results[key] = []
        var strippedArrString: String = String(String(parts[1]).dropFirst(2).dropLast())
        strippedArrString = strippedArrString.replacingOccurrences(of: "], [", with: "]; [")
        let resultsArr = strippedArrString.components(separatedBy: ";")
        for result in resultsArr {
            let arrForm = result.convertToDoubleArray()!
            results[key]!.append((arrForm[0], arrForm[1]))
        }
    }
    
    analyzeWeightsResults(results: results)
}

func analyzeWeightResultsFromStdin() {
    let line = readLine()
    analyzeWeightsResults(from: line!)
}


func analyzeWeightsResults(results: [[Double]: [(Double, Double)]] ){
    print("\(results.count) entries.")
    
    print("2^(Average log of board sum):")
    let mapped = results.mapValues{$0.map{log2($0.0)}}.mapValues{ave(arr: $0)}.map{$0}.sorted{$0.1 < $1.1}
    mapped.forEach{print("\($0.0): \(pow(2,$0.1))")}
    
    print("2^(Average log of highest piece):")
    let mapped2 = results.mapValues{$0.map{log2($0.1)}}.mapValues{ave(arr: $0)}.map{$0}.sorted{$0.1 < $1.1}
    mapped2.forEach{print("\($0.0): \(pow(2,$0.1))")}
    
}
