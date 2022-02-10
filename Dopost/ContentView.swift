//
//  ContentView.swift
//  Dopost
//
//  Created by Егор Пехота on 10.02.2022.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
    var body: some View {
        Form {
            HStack(alignment: .firstTextBaseline) {
                Text("Shortcut")
                KeyboardShortcuts.Recorder(for: .postData)
            }
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
