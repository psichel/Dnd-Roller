//
//  CreditsView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 11/3/20.
//

import SwiftUI
import MDText

struct CreditsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var markdownText: String = ""
    
    var body: some View {
        
        ScrollView {
            MDText(markdown: markdownText)
                .padding()
        }
        .onAppear {
            getCreditsText()
        }

    }
    
    func getCreditsText() {
        guard let fileURL = Bundle.main.url(forResource: "Credits", withExtension: "md")
        else {
            print("Did not find resource Credits.md")
            return
        }
        do {
            markdownText = try String(contentsOf: fileURL)
        } catch {
            print(error)
            // Handle the error
        }
    }
    
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
