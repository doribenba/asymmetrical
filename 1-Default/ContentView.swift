//
//  ContentView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/26.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedUIImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedColor: Color = .white
    @State var renderedImage: UIImage?

    var body: some View {
        ZStack{
            selectedColor.inverted()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: selectedColor)
            VStack {
                if let image = selectedUIImage {
                    EditorView(selectedItem: $selectedItem, selectedUIImage: $selectedUIImage, selectedColor: $selectedColor, image: image, renderedImage: $renderedImage)
                } else {
                    SplashView(selectedColor: selectedColor, selectedItem: $selectedItem, renderedImage: $renderedImage)
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                guard let newValue else { return }
                
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        withAnimation {
                            selectedUIImage = image
                        }
                    }
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
}
