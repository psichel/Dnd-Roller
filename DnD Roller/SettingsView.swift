//
//  SettingsView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 11/11/20.
//

import SwiftUI

struct SettingsView: View {
    var cx: ContentView
    
    @AppStorage("enableSound") private var enableSound = true
    @AppStorage("enableAnimation") private var enableAnimation = true
    @AppStorage("enableHaptic") private var enableHaptic = true
    
    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                Toggle("Sound", isOn: $enableSound)
                Toggle("Animation", isOn: $enableAnimation)
                Toggle("Haptic", isOn: $enableHaptic)
                Button("Reset Dice") {
                    cx.resetDice()
                }
                NavigationLink(destination: CreditsView()) {
                    Text("Credits")
                }
            }
            Section(header: Text("Average over last 10 rolls")) {
                ForEach (0..<cx.myDice.diceArray.count, id:\.self) { row in
                    HStack {
                        Text("d\(cx.myDice.diceArray[row].sides)")
                                        .font(.system(size: 20))
                        Spacer()
                        Text(cx.myDice.diceArray[row].diceStats.average)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(cx: ContentView())
    }
}
