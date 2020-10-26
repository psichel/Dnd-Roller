//
//  JaeView.swift
//  DnD Roller
//
//  Created by Peter Sichel on 10/26/20.
//

import SwiftUI

struct JaeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing:50) {
            Text("Jae is awesome")
                .font(.largeTitle)
                .foregroundColor(.purple)
            Button("Dismiss") {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct JaeView_Previews: PreviewProvider {
    static var previews: some View {
        JaeView()
    }
}
