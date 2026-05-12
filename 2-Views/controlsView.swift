//
//  controlsView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/30.
//

import SwiftUI

struct ControlsView: View {
    @Binding var selectedColor: Color
    @Binding var borderSize: Float
//    @State var transparent: Bool = false
    
    var body: some View {
        VStack{
            ColorPicker("BORDER COLOR ->", selection: $selectedColor)
                .foregroundStyle(selectedColor)
                .monospaced()
                .fontWeight(.bold)
            HStack{
                Slider(value: $borderSize, in: 0...100, step: 5)
                    .preferredColorScheme(selectedColor.isdark ? .light : .dark)
                    .tint(Color.darkBlue)
                Text(" WIDTH")
                    .monospaced()
                    .fontWeight(.bold)
                    .foregroundStyle(selectedColor)
            }
        }
    }
}
