//
//  TinyCalApp.swift
//  TinyCal
//
//  Created by Alfred Chan on 22/3/2026.
//

import SwiftUI

@main
struct TinyCalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 320, idealWidth: 380, maxWidth: 500,
                       minHeight: 360, idealHeight: 420, maxHeight: 600)
                #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
    }
}
