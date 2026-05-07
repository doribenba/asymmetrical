//
//  editor.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/28.
//
//
import SwiftUI
import PhotosUI

struct EditorView: View {
    
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedUIImage: UIImage?
    @Binding var selectedColor: Color
    @State private var borderSize: Float = 20
    
    let image: UIImage
    @Binding var renderedImage: UIImage?
    
    var body: some View {
            
            VStack(alignment: .leading){
                HeaderView(
                    selectedItem: $selectedItem,
                    selectedUIImage: $selectedUIImage,
                    selectedColor: selectedColor,
                    borderSize: borderSize,
                    image: image, renderedImage: $renderedImage
                )
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(CGFloat(borderSize)/2)
                    .background(selectedColor)
                    .compositingGroup()
                    .padding(.vertical, 13)
                    .animation(.easeInOut(duration: 0.1), value: selectedColor)
                
                ControlsView(selectedColor: $selectedColor, borderSize: $borderSize)
            }
            .padding(40)
        }
}
