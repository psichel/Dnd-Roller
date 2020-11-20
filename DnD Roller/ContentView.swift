//
//  ContentView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 10/22/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var myDice = Dice()
    @State private var dieIndex = 1
    @State private var customDieOffset = 6      // must be updated if array size changes
    @State private var animationAmount = 0.0
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingJaeSheet = false
    
    var body: some View {
        
        NavigationView {
            if verticalSizeClass == .regular {
                VStack {
                    List {
                        ForEach (0..<myDice.diceArray.count-1, id:\.self) { i in
                            dieTableRow(cx: self, row:i)
                                //.frame(height: 30)
                        }
                        customDieTableRow(cx: self, row:customDieOffset)
                    }
                    .environment(\.defaultMinListRowHeight, 10)
                    resultView(cx: self)
                }
                .navigationBarTitle("DnD Roller", displayMode: .inline)
                .navigationBarItems(trailing:
                    NavigationLink(destination: SettingsView(cx: self)) {
                        Text("Settings")
                            //.foregroundColor(Color("diceBackground"))
                    }
                )
            }
            else {
                HStack {
                    Form {
                        ForEach (0..<myDice.diceArray.count-1, id:\.self) { i in
                            dieTableRow(cx: self, row:i)
                        }
                        customDieTableRow(cx: self, row:customDieOffset)
                    }
                    resultView(cx: self)
                }
                .navigationBarTitle("DnD Roller", displayMode: .inline)
                .navigationBarItems(trailing:
                    NavigationLink(destination: SettingsView(cx: self)) {
                        Text("Settings")
                            .foregroundColor(Color("diceBackground"))
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            let initialized = UserDefaults.standard.bool(forKey: "initialized")
            if !initialized {
                UserDefaults.standard.set(true, forKey: "initialized")
                UserDefaults.standard.set(true, forKey: "enableSound")
                UserDefaults.standard.set(true, forKey: "enableAnimation")
            }
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
                    cx.myDice.calculateRoll(die: cx.myDice.diceArray[row])
                    cx.animationAmount += 640
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
                Spacer()
                Button(action: {
                    self.hideKeyboard()
                    let strValue = cx.myDice.diceArray[row].sidesStr
                    switch (strValue) {
                    case "0402":
                        cx.showingJaeSheet.toggle()
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
                        cx.myDice.rollMessage = "Please enter a valid number of sides."
                        return
                    }
                    cx.myDice.diceArray[row].sides = value
                    cx.dieIndex = row      // used by resultView
                    cx.myDice.calculateRoll(die: cx.myDice.diceArray[row])
                    cx.animationAmount += 640
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
    
    func resetDice() {
        myDice.diceArray = Dice.defaultDice
        _ = myDice.diceArray.map { $0.diceStats.history.removeAll() }
        myDice.diceArray[customDieOffset].sidesStr = "100"
        dieIndex = 1
        myDice.rollMessage = ""
    }
    
    struct resultView: View {
        var cx: ContentView
        let enableAnimation = UserDefaults.standard.bool(forKey: "enableAnimation")
        
        var body: some View {
            List {
                Text(cx.myDice.rollMessage)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .background(Color("diceBackground"))
                    .cornerRadius(10)
                Image(cx.myDice.diceArray[cx.dieIndex].imageName)
                    .rotationEffect(.degrees(cx.animationAmount))
                    .animation(enableAnimation ? Animation.easeOut(duration: 1.25) : Animation.linear(duration: 0.0))
                    .scaleEffect(cx.myDice.diceArray[cx.dieIndex].imageScale)
                    .frame(minWidth: 60, maxWidth: .infinity, minHeight: 60, maxHeight: .infinity, alignment: .center)
                    .padding(.vertical, -10)
            }
        }
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
