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
    @Binding var selectedDoubleBorderLayer: DoubleBorderLayer
    @Binding var doubleOuterBorderSize: Float
    @Binding var doubleInnerColor: Color
    @Binding var doubleInnerBorderSize: Float
    @Binding var selectedAspectRatio: AspectRatioOption
    @Binding var overlay: String
    @FocusState.Binding var isInputFocused: Bool
//    @State var transparent: Bool = false
    
    var body: some View {
        VStack{
            if selectedAspectRatio.isDouble {
                HStack(spacing: 10) {
                    
                    doubleModeButton("OUTER", layer: .outer)
                    doubleModeButton("INNER", layer: .inner)
                    
                    Spacer()

                    ColorPicker("", selection: activeDoubleColor)
                        .labelsHidden()
                    
                }
                HStack{
                    Slider(value: activeBorderSize, in: 0...100, step: 5)
                        .tint(Color.darkBlue)
                    Text(" WIDTH")
                        .monospaced()
                        .fontWeight(.bold)
                        .foregroundStyle(activeControlColor)
                }
            } else {
                if !selectedAspectRatio.isAsymmetrical {
                    ColorPicker("BORDER COLOR", selection: $selectedColor)
                        .foregroundStyle(selectedColor)
                        .monospaced()
                        .fontWeight(.bold)
                        .padding(.bottom, selectedAspectRatio.isAsymmetrical ? 8 : 0)
                    
                    HStack{
                        Slider(value: activeBorderSize, in: 0...100, step: 5)
                            .tint(Color.darkBlue)
                        Text(" WIDTH")
                            .monospaced()
                            .fontWeight(.bold)
                            .foregroundStyle(activeControlColor)
                    }
                } else {
                    HStack {
                        TextField("ENTER TEXT", text: $overlay)
                            .focused($isInputFocused)
                            .textInputAutocapitalization(.characters)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
        //                    .font(.system(.body, design: .monospaced, weight: .bold))
                            .foregroundStyle(selectedColor.opacity(0.55))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.secondary.opacity(0.15))
                            .cornerRadius(7)
                        
                        ColorPicker("", selection: $selectedColor)
                            .foregroundStyle(selectedColor)
                            .labelsHidden()
                    }
                    
                }
            }
//
//            if !selectedAspectRatio.isAsymmetrical {
//
//                ColorPicker("", selection: $selectedColor)
//                    .foregroundStyle(selectedColor)
//                    .monospaced()
//                    .padding(.bottom, selectedAspectRatio.isAsymmetrical ? 8 : 0)
//
//                HStack{
//                    Slider(value: activeBorderSize, in: 0...125, step: 5)
//                        .tint(Color.darkBlue)
//                    Text(" WIDTH")
//                        .monospaced()
//                        .fontWeight(.bold)
//                        .foregroundStyle(activeControlColor)
//                }
//            }
//            } else {
//                
////                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
////                    .fill(.secondary.opacity(0.55))
////                    .frame(height: 2)
////                    .padding(.vertical, 3)
////                    .padding(.bottom, 5)
//            
//                TextField("ENTER TEXT", text: $overlay)
//                    .textInputAutocapitalization(.characters)
//                    .font(.system(size: 13, weight: .bold, design: .monospaced))
////                    .font(.system(.body, design: .monospaced, weight: .bold))
//                    .foregroundStyle(selectedColor.opacity(0.55))
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(.secondary.opacity(0.15))
//                    .cornerRadius(7)
//            }
        }
        .preferredColorScheme(activeControlColor.isdark ? .light : .dark)
    }
    
    private var activeDoubleColor: Binding<Color> {
        Binding(
            get: {
                selectedDoubleBorderLayer == .outer ? selectedColor : doubleInnerColor
            },
            set: { newValue in
                if selectedDoubleBorderLayer == .outer {
                    selectedColor = newValue
                } else {
                    doubleInnerColor = newValue
                }
            }
        )
    }
    
    private var activeBorderSize: Binding<Float> {
        Binding(
            get: {
                guard selectedAspectRatio.isDouble else { return borderSize }
                return selectedDoubleBorderLayer == .outer ? doubleOuterBorderSize : doubleInnerBorderSize
            },
            set: { newValue in
                guard selectedAspectRatio.isDouble else {
                    borderSize = newValue
                    return
                }
                
                if selectedDoubleBorderLayer == .outer {
                    doubleOuterBorderSize = newValue
                } else {
                    doubleInnerBorderSize = newValue
                }
            }
        )
    }
    
    private var activeControlColor: Color {
        return selectedColor
    }
    
    private func doubleModeButton(_ title: String, layer: DoubleBorderLayer) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedDoubleBorderLayer = layer
            }
        } label: {
            let isSelected = selectedDoubleBorderLayer == layer
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .monospaced()
                .frame(height: 18)
                .foregroundStyle(isSelected ? activeControlColor : .secondary)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(.secondary.opacity(isSelected ? 0.20 : 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
