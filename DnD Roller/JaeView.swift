//
//  JaeView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 10/26/20.
//

import SwiftUI

struct JaeView: View {
    @Environment(\.presentationMode) var presentationMode
    let easterEggs = ["Crocnessmonster falls into lava yummy side up",
                      "Authoritative sloth",
                      "Penny & Ruby & Lollipop & Pikaya & Elska",
                      "Toast for days",
                      "Do it or don’t do it or do it",
                      "The answer is: Twenty seven....and a half",
                      "You have found the third dimple",
                    ]
    
    var body: some View {
        VStack(spacing:50) {
            Text(easterEggs.randomElement() ?? "Jae is awesome")
                .font(.largeTitle)
                .foregroundColor(.purple)
            Button("Dismiss") {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}

struct JaeView_Previews: PreviewProvider {
    static var previews: some View {
        JaeView()
    }
}
