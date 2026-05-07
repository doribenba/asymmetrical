//
//  splash.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/28.
//

import SwiftUI
import PhotosUI
import ConfettiSwiftUI

struct SplashView: View {
    let selectedColor: Color
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var renderedImage: UIImage?
    @State private var confetti: Int = 0
    @State private var imageScale: CGFloat = 0.78
    @State private var imageOpacity: Double = 0
    @State private var imageRotation: Double = -4
    
    var body: some View {
        if let render = renderedImage {
            VStack(alignment: .leading){
                HStack{
                    Spacer()
                    Text("SAVED!")
                        .monospaced()
                        .foregroundStyle(selectedColor)
                }
                Image(uiImage: render)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 13)
                    .scaleEffect(imageScale)
                    .rotationEffect(.degrees(imageRotation))
                Spacer().frame(height: 60)
            }
            .padding(40)
            .task {
                try? await Task.sleep(nanoseconds: 3_150_000_000)
                
                withAnimation(.spring(response: 0.34, dampingFraction: 0.55, blendDuration: 0.05)) {
                    imageScale = 0.78
                    imageOpacity = 0
                    imageRotation = 4
                }
                
                try? await Task.sleep(nanoseconds: 450_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    renderedImage = nil
                }
            }
            .onAppear(perform: {
                imageScale = 0.78
                imageOpacity = 0
                imageRotation = -4
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.48, blendDuration: 0.05)) {
                        imageScale = 1
                        confetti += 1
                        imageOpacity = 1
                        imageRotation = 0
                    }
                }
            })
            .confettiCannon(trigger: $confetti, num: 69, rainHeight: 300, radius: 400.0, hapticFeedback: true)
            .opacity(imageOpacity)
            
        } else {
            ZStack{
                selectedColor.inverted()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: selectedColor)
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("<- border", systemImage: "photo")
                        .bold()
                        .tint(selectedColor)
                }
                .tint(.black)
                .monospaced()
            }
        }
    }
}
