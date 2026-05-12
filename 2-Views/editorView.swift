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
    @Binding var selectedBatchItems: [PhotosPickerItem]
    @Binding var selectedUIImage: UIImage?
    @Binding var batchImages: [UIImage]
    @Binding var selectedColor: Color
    @State private var borderSize: Float = 20
    @State private var isBorderSizeOverlayVisible = false
    @State private var borderSizeOverlayGeneration = 0
    @State private var selectedAspectRatio = AspectRatioOption.original
    
    let image: UIImage
    var isBatchMode = false
    let onRenderedImage: (UIImage, Bool, Bool) -> Void
    let onBatchExportComplete: () -> Void
    
    var body: some View {
            
        VStack(alignment: .leading){
                HeaderView(
                    selectedItem: $selectedItem,
                    selectedBatchItems: $selectedBatchItems,
                    selectedUIImage: $selectedUIImage,
                    batchImages: $batchImages,
                    selectedAspectRatio: $selectedAspectRatio,
                    selectedColor: selectedColor,
                    borderSize: borderSize,
                    image: image,
                    isBatchMode: isBatchMode,
                    onRenderedImage: onRenderedImage,
                    onBatchExportComplete: onBatchExportComplete
                )
                
                ZStack {
                    if isBatchMode {
                        if let displayImage = batchImages.first {
                            if selectedAspectRatio.ratio == nil {
                                
                                Image(uiImage: displayImage)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(CGFloat(borderSize)/2)
                                    .background(selectedColor)
                                    .compositingGroup()
                                
                            } else {
                                ZStack {
                                    selectedColor
                                    
                                    Image(uiImage: displayImage)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(CGFloat(borderSize)/2)
                                }
                                .aspectRatio(previewAspectRatio, contentMode: .fit)
                                .compositingGroup()
                            }
                        }
                    } else {
                        if selectedAspectRatio.ratio == nil {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding(CGFloat(borderSize)/2)
                                .background(selectedColor)
                                .compositingGroup()
                        } else {
                            ZStack {
                                selectedColor
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(CGFloat(borderSize)/2)
                            }
                            .aspectRatio(previewAspectRatio, contentMode: .fit)
                            .compositingGroup()
                        }
                    }
                    
                    if isBorderSizeOverlayVisible {
                        Text("\(Int(borderSize))")
                            .font(.system(size: 50, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .blendMode(.difference)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                }
                .padding(.top, 13)
                .padding(.bottom, 9)
                .animation(.easeInOut(duration: 0.1), value: selectedColor)
                .animation(.easeInOut(duration: 0.18), value: selectedAspectRatio)
                .onChange(of: borderSize) { _, _ in
                    showBorderSizeOverlay()
                }
                
                ControlsView(selectedColor: $selectedColor, borderSize: $borderSize)
            }
            .padding(40)
        }
    
    private var previewAspectRatio: CGFloat {
        selectedAspectRatio.ratio ?? (isBatchMode ? 1 : evenBorderAspectRatio)
    }
    
    private var evenBorderAspectRatio: CGFloat {
        let originalSize = image.size
        let base = min(originalSize.width, originalSize.height)
        let border = base * (CGFloat(borderSize / 4) / 100)
        return (originalSize.width + border * 2) / (originalSize.height + border * 2)
    }
    
    private func showBorderSizeOverlay() {
        borderSizeOverlayGeneration += 1
        let currentGeneration = borderSizeOverlayGeneration
        
        withAnimation(.easeOut(duration: 0.12)) {
            isBorderSizeOverlayVisible = true
        }
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            
            if borderSizeOverlayGeneration == currentGeneration {
                withAnimation(.easeOut(duration: 0.2)) {
                    isBorderSizeOverlayVisible = false
                }
            }
        }
    }
}
