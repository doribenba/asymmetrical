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
    @State private var selectedDoubleBorderLayer: DoubleBorderLayer = .outer
    @State private var doubleOuterBorderSize: Float = 20
    @State private var doubleInnerColor: Color = .black
    @State private var doubleInnerBorderSize: Float = 20
    
    @State private var overlayText: String = "ASYMMETRICAL"
    
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
                    selectedColor: activeControlColor,
                    borderSize: borderSize,
                    doubleOuterColor: selectedColor,
                    doubleOuterBorderSize: doubleOuterBorderSize,
                    doubleInnerColor: doubleInnerColor,
                    doubleInnerBorderSize: doubleInnerBorderSize,
                    overlayText: overlayText,
                    image: image,
                    isBatchMode: isBatchMode,
                    onRenderedImage: onRenderedImage,
                    onBatchExportComplete: onBatchExportComplete
                )
                
                ZStack {
                    if isBatchMode {
                        if selectedAspectRatio.isAsymmetrical {
                            asymmetricalPreview
                        } else if selectedAspectRatio.isDouble {
                            doubleBorderPreview
                        } else if selectedAspectRatio.ratio == nil {
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
                    } else {
                        if selectedAspectRatio.isAsymmetrical {
                            asymmetricalPreview
                        } else if selectedAspectRatio.isDouble {
                            doubleBorderPreview
                        } else if selectedAspectRatio.ratio == nil {
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
                        Text("\(Int(activeBorderSizeValue))")
                            .font(.system(size: 50, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .blendMode(.difference)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                }
                .padding(.top, 13)
                .padding(.bottom, 9)
                .animation(.easeInOut(duration: 0.1), value: selectedColor)
                .animation(.easeInOut(duration: 0.1), value: doubleInnerColor)
                .animation(.easeInOut(duration: 0.18), value: selectedAspectRatio)
                .onChange(of: borderSize) { _, _ in
                    showBorderSizeOverlay()
                }
                .onChange(of: doubleOuterBorderSize) { _, _ in
                    guard selectedAspectRatio.isDouble, selectedDoubleBorderLayer == .outer else { return }
                    showBorderSizeOverlay()
                }
                .onChange(of: doubleInnerBorderSize) { _, _ in
                    guard selectedAspectRatio.isDouble, selectedDoubleBorderLayer == .inner else { return }
                    showBorderSizeOverlay()
                }
                
            ControlsView(
                selectedColor: $selectedColor,
                borderSize: $borderSize,
                selectedDoubleBorderLayer: $selectedDoubleBorderLayer,
                doubleOuterBorderSize: $doubleOuterBorderSize,
                doubleInnerColor: $doubleInnerColor,
                doubleInnerBorderSize: $doubleInnerBorderSize,
                selectedAspectRatio: $selectedAspectRatio,
                overlay: $overlayText
            )
            }
            .padding(40)
        }
    
    private var previewAspectRatio: CGFloat {
        selectedAspectRatio.ratio ?? (isBatchMode ? 1 : evenBorderAspectRatio)
    }
    
    private var asymmetricalPreview: some View {
        GeometryReader { proxy in
            let contentRect = AsymmetricalBorderLayout.contentRect(for: image.size, in: proxy.size)
            
            ZStack(alignment: .topLeading) {
                selectedColor
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: contentRect.width, height: contentRect.height)
                    .position(x: contentRect.midX, y: contentRect.midY)
                
                asymmetricalOverlayText(in: proxy.size, contentRect: contentRect)
            }
        }
        .aspectRatio(asymmetricalBorderAspectRatio, contentMode: .fit)
        .compositingGroup()
    }
    
    private var doubleBorderPreview: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .padding(CGFloat(doubleInnerBorderSize) / 2)
            .background(doubleInnerColor)
            .padding(CGFloat(doubleOuterBorderSize) / 2)
            .background(selectedColor)
            .compositingGroup()
    }
    
    @ViewBuilder
    private func asymmetricalOverlayText(in size: CGSize, contentRect: CGRect) -> some View {
        let text = overlayText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            let bottomHeight = max(0, size.height - contentRect.maxY)
            
            Text(text)
                .font(.system(size: max(8, bottomHeight * 0.78), weight: .bold, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(selectedColor.isdark ? .white : .black)
                .frame(width: contentRect.width, height: bottomHeight, alignment: .leading)
                .position(x: contentRect.midX, y: contentRect.maxY + bottomHeight / 2)
        }
    }
    
    private var asymmetricalBorderAspectRatio: CGFloat {
        AsymmetricalBorderLayout.canvasSize(for: image.size).width / AsymmetricalBorderLayout.canvasSize(for: image.size).height
    }
    
    private var evenBorderAspectRatio: CGFloat {
        let originalSize = image.size
        let base = min(originalSize.width, originalSize.height)
        let border = base * (CGFloat(borderSize / 4) / 100)
        return (originalSize.width + border * 2) / (originalSize.height + border * 2)
    }
    
    private var activeControlColor: Color {
        return selectedColor
    }
    
    private var activeBorderSizeValue: Float {
        guard selectedAspectRatio.isDouble else { return borderSize }
        return selectedDoubleBorderLayer == .outer ? doubleOuterBorderSize : doubleInnerBorderSize
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
