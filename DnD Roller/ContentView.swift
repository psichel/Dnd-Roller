//
//  ContentView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 10/22/20.
//

import SwiftUI

struct ContentView: View {

    @State private var dice = [
        Die(sides: 4, imageName: "dice4"),
        Die(sides: 6, imageName: "dice6"),
        Die(sides: 8, imageName: "dice8"),
        Die(sides: 10, imageName: "dice10"),
        Die(sides: 12, imageName: "dice12"),
        Die(sides: 20, imageName: "dice20"),
        //Die(sides: 100),
        Die(sides: 17, imageName: "dice20"),     // last one has custom number of sides
    ]
    @State private var dieIndex = 0
    @State private var rollMessage = ""
    
    @State private var customSidesTxt = ""
    @State private var customSides = 17
    @State private var customIndex = 6      // must be updated if array size changes
    @State private var animationAmount = 0.0
    @Environment(\.verticalSizeClass) var sizeClass
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    ForEach (0..<dice.count-1, id:\.self) { i in
                        HStack {
                            Stepper(value: $dice[i].howMany, in: 1...10, step: 1) {
                                Text("\(dice[i].howMany)")
                            }
                            .labelsHidden()
                            Text("\(dice[i].howMany) d\(dice[i].sides)")
                                .font(.system(size: 20))
                            Spacer()
                            Button(action: {
                                self.hideKeyboard()
                                dieIndex = i
                                calculateRoll(die: dice[i])
                                withAnimation(.linear(duration: 1.25)) {
                                    self.animationAmount += 640
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
                    customDieView(cx: self)
                }
                resultView(cx: self)
            }
            .navigationBarTitle("DnD Roller")
            .padding([.bottom], -1)
        }
        
    }
    
// MARK: - subviews
    struct commonDieView: View {
        var cx: ContentView
        
        var body: some View {
            Text("Hello World!")
        }
    }
    
    struct customDieView: View {
        var cx: ContentView
        
        var body: some View {
            HStack {
                // custom number of sides
                Stepper(value: cx.$dice[cx.customIndex].howMany, in: 1...10, step: 1) {
                    Text("\(cx.dice[cx.customIndex].howMany)")
                }
                .labelsHidden()
                Text("\(cx.dice[cx.customIndex].howMany) d")
                    .font(.system(size: 20))
                TextField("Number of sides", text: cx.$customSidesTxt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Spacer()
                Button(action: {
                    if let value = Int(cx.customSidesTxt) {
                        self.hideKeyboard()
                        cx.dieIndex = cx.customIndex
                        cx.dice[cx.customIndex].sides = value
                        cx.calculateRoll(die: cx.dice[cx.customIndex])
                        withAnimation(.linear(duration: 1.25)) {
                            cx.animationAmount += 640
                        }
                    }
                    else { cx.customSidesTxt = ""
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
        }
    }

    struct resultView: View {
        var cx: ContentView
        var body: some View {
            VStack {
                Text(cx.rollMessage)
                    .font(.largeTitle)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: .infinity, alignment: .leading)
                Image(cx.dice[cx.dieIndex].imageName)
                    .rotation3DEffect(.degrees(cx.animationAmount), axis: (x: 0, y: 0, z: 1))
            }
        }
    }

// MARK: Preview
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

    struct Die: Identifiable, Codable {
        var id = UUID()
        var sides: Int
        var howMany = 1
        var imageName: String
        
        func rollDie() -> Int {
            let total = Int.random(in: 1...sides)
            return total
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

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
