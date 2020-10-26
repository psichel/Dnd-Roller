//
//  ContentView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 10/22/20.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var myDice = Dice()
    @State private var dieIndex = 0
    @State private var rollMessage = ""
    @State private var customDieOffset = 6      // must be updated if array size changes
    @State private var animationAmount = 0.0
    @Environment(\.verticalSizeClass) var sizeClass
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    ForEach (0..<myDice.diceArray.count-1, id:\.self) { i in
                        dieTableRow(cx: self, row:i)
                    }
                    customDieTableRow(cx: self, row:customDieOffset)
                }
                Section {
                    resultView(cx: self)
                }
            }
            .navigationBarTitle("DnD Roller")
            .padding([.bottom], -1)
        }
        
    }

// MARK: - subviews
    struct dieTableRow: View {
        var cx: ContentView
        var row: Int
        
        var body: some View {
            HStack {
                Stepper(value: cx.$myDice.diceArray[row].howMany, in: 1...10, step: 1) {
                    Text("\(cx.myDice.diceArray[row].howMany)")
                }
                .labelsHidden()
                Text("\(cx.myDice.diceArray[row].howMany) d\(cx.myDice.diceArray[row].sides)")
                    .font(.system(size: 20))
                Spacer()
                Button(action: {
                    self.hideKeyboard()
                    cx.dieIndex = row   // used by resultView
                    cx.calculateRoll(die: cx.myDice.diceArray[row])
                    withAnimation(.linear(duration: 1.25)) {
                        cx.animationAmount += 640
                    }
                                
                }) {
                    Text("Roll")
                        .padding(4)
                        .foregroundColor(Color(.label))
                        .background(Color.yellow)
                        .cornerRadius(7)
                }
            }
        }
    }
    
    struct customDieTableRow: View {
        var cx: ContentView
        var row: Int
        
        var body: some View {
            HStack {
                // custom number of sides
                Stepper(value: cx.$myDice.diceArray[row].howMany, in: 1...10, step: 1) {
                    Text("\(cx.myDice.diceArray[row].howMany)")
                }
                .labelsHidden()
                Text("\(cx.myDice.diceArray[row].howMany) d")
                    .font(.system(size: 20))
                TextField("Number of sides", text: cx.$myDice.diceArray[row].sidesStr)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Spacer()
                Button(action: {
                    if let value = Int(cx.myDice.diceArray[row].sidesStr) {
                        cx.myDice.diceArray[row].sides = value
                        self.hideKeyboard()
                        cx.dieIndex = row      // used by resultView
                        cx.calculateRoll(die: cx.myDice.diceArray[row])
                        withAnimation(.linear(duration: 1.25)) {
                            cx.animationAmount += 640
                        }
                    }
                    else { cx.myDice.diceArray[row].sidesStr = ""
                        cx.rollMessage = "Please enter a valid number of sides."
                    }
                }) {
                    Text("Roll")
                        .padding(4)
                        .foregroundColor(Color(.label))
                        .background(Color.yellow)
                        .cornerRadius(7)
                }
            }
            .onAppear() {
                print("Hello World")
            }
        }
    }

    struct resultView: View {
        var cx: ContentView
        
        var body: some View {
            List {
                Section {
                    Text(cx.rollMessage)
                        .font(.largeTitle)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: .infinity, alignment: .leading)
                }
                Image(cx.myDice.diceArray[cx.dieIndex].imageName)
                    .rotation3DEffect(.degrees(cx.animationAmount), axis: (x: 0, y: 0, z: 1))
            }
        }
    }

    
    func calculateRoll(die: Die) {
        var total = 0;
        self.rollMessage = "Roll \(die.howMany) d\(die.sides)\n"
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
        if (die.howMany > 1) { rollMessage += " = \(total)" }
    }
    
}


// MARK: - Die and Dice
struct Die: Identifiable, Codable {
    var id = UUID()
    var sides: Int
    var sidesStr = ""   // used for TextField binding
    var howMany = 1
    var imageName: String
    
    func rollDie() -> Int {
        let total = Int.random(in: 1...sides)
        return total
    }
}

// Collection of Dice with defaults plus save and restore from UserDefaults
class Dice: ObservableObject {
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

        self.diceArray = [
            Die(sides: 4, imageName: "dice4"),
            Die(sides: 6, imageName: "dice6"),
            Die(sides: 8, imageName: "dice8"),
            Die(sides: 10, imageName: "dice10"),
            Die(sides: 12, imageName: "dice12"),
            Die(sides: 20, imageName: "dice20"),
            //Die(sides: 100),
            Die(sides: 17, imageName: "dice20"),     // last one has custom number of sides
        ]
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
