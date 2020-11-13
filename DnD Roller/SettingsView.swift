//
//  SettingsView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 11/11/20.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("enableSound") private var enableSound = true
    @AppStorage("enableAnimation") private var enableAnimation = true
    @AppStorage("enableDarkMode") private var enableDarkMode = false
    @State private var showingCreditsSheet = false
    
    var body: some View {
        Form {
            Toggle("Sound", isOn: $enableSound)
            Toggle("Animation", isOn: $enableAnimation)
            Button("Credits", action: { showingCreditsSheet.toggle() })
        }
        .sheet(isPresented: $showingCreditsSheet) {
            CreditsView()
        }
        
        Button("Dismiss") {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
