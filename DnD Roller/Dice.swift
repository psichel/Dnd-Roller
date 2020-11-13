//
//  Dice.swift
//  DnD Roller
//
//  Created by Peter Sichel on 11/4/20.
//

import Foundation
import SwiftUI

let myAudio = MyAudio()

struct Die: Identifiable, Codable {
    var id = UUID()
    var sides: Int
    var sidesStr = ""   // used for TextField binding
    var howMany = 1
    var imageName: String
    var imageScale: CGSize
    var history = [Int]()
    var average: String {
        get {
            //history.count > 0 ? "\( Double(history.reduce(0, +)) / Double(history.count) )" : ""
            history.count > 0 ? String( format: "%.1f", Double(history.reduce(0, +)) / Double(history.count) ) : ""
        }
    }
    
    mutating func rollDie() -> Int {
        let total = Int.random(in: 1...sides)
        history.append(total)
        let arraySlice = history.prefix(20)
        history = Array(arraySlice)
        return total
    }
}

// Collection of Dice with defaults plus save and restore from UserDefaults
class Dice: ObservableObject {
    static let defaultDice = [
        Die(sides: 4, imageName: "dice4", imageScale: CGSize(width: 0.55, height: 0.55)),
        Die(sides: 6, imageName: "dice6", imageScale: CGSize(width: 0.55, height: 0.55)),
        Die(sides: 8, imageName: "dice8", imageScale: CGSize(width: 0.6, height: 0.6)),
        Die(sides: 10, imageName: "dice10", imageScale: CGSize(width: 0.6, height: 0.6)),
        Die(sides: 12, imageName: "dice12", imageScale: CGSize(width: 0.55, height: 0.55)),
        Die(sides: 20, imageName: "dice20", imageScale: CGSize(width: 0.65, height: 0.65)),
        //Die(sides: 100),
        Die(sides: 100, imageName: "dice_any", imageScale: CGSize(width: 0.55, height: 0.55)),     // last one has custom number of sides
    ]
    var rollMessage = ""
    
    @Published var diceArray: [Die] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(diceArray) {
                UserDefaults.standard.set(encoded, forKey: "Dice")
            }
        }
    }
    
    init() {
        if let diceArray = UserDefaults.standard.data(forKey: "Dice") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Die].self, from: diceArray) {
                self.diceArray = decoded
                return
            }
        }
        diceArray = Dice.defaultDice
        diceArray[diceArray.count-1].sidesStr = "100"
    }
    
    func calculateRoll( die: inout Die) {
        var total = 0;
        rollMessage = "Roll \(die.howMany) d\(die.sides)\n"
        for i in 0..<die.howMany {
            let value = die.rollDie()
            total += value
            if (i == 0) {
                rollMessage += "\(value)"
            }
            else {
                rollMessage += " + \(value)"
            }
        }
        if die.howMany > 1 { rollMessage += " = \(total)" }
        
        let enableSound = UserDefaults.standard.bool(forKey: "enableSound")
        if die.howMany == 1 && die.sides == 20 && enableSound {
            if total == 1 {
                myAudio.playSound(name: "WahWah")
            }
            else if total == die.sides {
                myAudio.playSound(name: "Success")
            }
            else {
                myAudio.playSound(name: "Roll")
            }
        }
        else if enableSound {
            myAudio.playSound(name: "Roll")
        }
    }
    
}


