//
//  splashScreenView.swift
//  borders
//
//  Created by Dorian Benbassat on 2026/7/11.
//

import SwiftUI

struct splashScreenView: View {
    
    @State private var opacity = 1.0
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            Image("Icon")
                .resizable()
                .frame(width: 100, height: 100)
                .opacity(opacity)
                .task {
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation(.easeOut(duration: 0.2)) {
                        opacity = 0
                    }
                }
        }
    }
}

#Preview {
    splashScreenView()
}
