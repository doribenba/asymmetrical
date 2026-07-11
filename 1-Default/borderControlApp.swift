//
//  borderControlApp.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/26.
//

import SwiftUI

@main

struct bordersApp: App {
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            if showSplash && !hasLaunchedBefore {
                splashScreenView()
                    .task {
                        try? await Task.sleep(for: .seconds(3.3))
                        hasLaunchedBefore = true
                        withAnimation {
                            showSplash = false
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
