//
//  ContentView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 10/22/20.
//

import SwiftUI

let myAudio = MyAudio()

struct ContentView: View {

    @ObservedObject var myDice = Dice()
    @State private var dieIndex = 1
    @State private var rollMessage = ""
    @State private var customDieOffset = 6      // must be updated if array size changes
    @State private var animationAmount = 0.0
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingJaeSheet = false
    @State private var showingCreditsSheet = false
    
    var body: some View {
        
        NavigationView {
            if verticalSizeClass == .regular {
                VStack {
                    List {
                        ForEach (0..<myDice.diceArray.count-1, id:\.self) { i in
                            dieTableRow(cx: self, row:i)
                                .frame(height: 30)
                        }
                        customDieTableRow(cx: self, row:customDieOffset)
                        resetView(cx: self)
                    }
                    .environment(\.defaultMinListRowHeight, 10)
                    resultView(cx: self)
                }
                .navigationBarTitle("DnD Roller", displayMode: .inline)
            }
            else {
                HStack {
                    Form {
                        ForEach (0..<myDice.diceArray.count-1, id:\.self) { i in
                            dieTableRow(cx: self, row:i)
                        }
                        customDieTableRow(cx: self, row:customDieOffset)
                        resetView(cx: self)
                    }
                    resultView(cx: self)
                }
                .navigationBarTitle("DnD Roller", displayMode: .inline)
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())

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
                        .frame(width: 60, height: nil)
                        .padding(4)
                        .foregroundColor(Color.white)
                        .background(Color("diceBackground"))
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
                TextField("#", text: cx.$myDice.diceArray[row].sidesStr)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .frame(width: 60, height: nil)
                    .sheet(isPresented: cx.$showingCreditsSheet) {
                                CreditsView()
                    }
                Spacer()
                Button(action: {
                    self.hideKeyboard()
                    let strValue = cx.myDice.diceArray[row].sidesStr
                    switch (strValue) {
                    case "0402":
                        cx.showingJaeSheet.toggle()
                        return
                    case "00":
                        cx.showingCreditsSheet.toggle()
                        return
                    case "01":
                        myAudio.playSound(name: "WahWah")
                        return
                    case "02":
                        myAudio.playSound(name: "Success")
                        return
                    default: break
                    }
                    guard let value = Int(strValue),
                              value >= 1
                    else {
                        cx.myDice.diceArray[row].sidesStr = ""
                        cx.rollMessage = "Please enter a valid number of sides."
                        return
                    }
                    cx.myDice.diceArray[row].sides = value
                    cx.dieIndex = row      // used by resultView
                    cx.calculateRoll(die: cx.myDice.diceArray[row])
                    withAnimation(.linear(duration: 1.25)) {
                        cx.animationAmount += 640
                    }
                }) {
                    Text("Roll")
                        .frame(width: 60, height: nil)
                        .padding(4)
                        .foregroundColor(Color.white)
                        .background(Color("diceBackground"))
                        .cornerRadius(7)
                }
                .sheet(isPresented: cx.$showingJaeSheet) {
                            JaeView()
                }
            }
        }
    }

    struct resetView: View {
        var cx: ContentView
        
        var body: some View {
            HStack {
                Spacer()
                Button("reset") {
                    cx.myDice.diceArray = Dice.defaultDice
                    cx.myDice.diceArray[cx.customDieOffset].sidesStr = "100"
                    cx.dieIndex = 1
                    cx.rollMessage = ""
                }
            }
        }
    }
    
    struct resultView: View {
        var cx: ContentView
        
        var body: some View {
            List {
                Text(cx.rollMessage)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .background(Color("diceBackground"))
                    .cornerRadius(10)
                Image(cx.myDice.diceArray[cx.dieIndex].imageName)
                    .padding(.vertical, -30)
                    .scaleEffect(cx.myDice.diceArray[cx.dieIndex].imageScale)
                    .frame(minWidth: 60, maxWidth: .infinity, minHeight: 60, maxHeight: .infinity, alignment: .center)
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
        if die.howMany > 1 { rollMessage += " = \(total)" }
        
        if die.howMany == 1 && die.sides == 20 {
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
        else {
            myAudio.playSound(name: "Roll")
        }
    }
    
}


// MARK: - Die and Dice
struct Die: Identifiable, Codable {
    var id = UUID()
    var sides: Int
    var sidesStr = ""   // used for TextField binding
    var howMany = 1
    var imageName: String
    var imageScale: CGSize
    
    func rollDie() -> Int {
        let total = Int.random(in: 1...sides)
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
