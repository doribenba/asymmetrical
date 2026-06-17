//
//  ContentView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/26.
//

import SwiftUI
import PhotosUI
import StoreKit

struct RenderedExportImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let isFinal: Bool
}

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @State private var selectedUIImage: UIImage?
    @State private var pendingReviewPrompt = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedBatchItems: [PhotosPickerItem] = []
    @State private var batchImages: [UIImage] = []
    @State private var selectedColor: Color = .white
    @State var renderedImage: UIImage?
    @State private var renderedImageQueue: [UIImage] = []
    @State private var renderedImageGeneration = 0
    @State private var batchRenderedImages: [RenderedExportImage] = []
    @State private var isBatchExportAnimationActive = false
    @State private var isBatchExportBackdropVisible = false
    @State private var isBatchExportComplete = false

    var body: some View {
        ZStack{
            selectedColor.inverted()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: selectedColor)
            ZStack {
                if renderedImage != nil || isBatchExportAnimationActive {
                    SplashView(
                        selectedColor: selectedColor,
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        renderedImage: $renderedImage,
                        batchRenderedImages: $batchRenderedImages,
                        isBatchExportAnimationActive: isBatchExportAnimationActive,
                        renderedImageGeneration: renderedImageGeneration,
                        onRenderedImageDismissed: showNextRenderedImage,
                        onBatchRenderedImageDismissed: removeBatchRenderedImage
                    )
                    .transition(.opacity)
                } else if isBatchExportBackdropVisible {
                    Color.clear
                        .transition(.opacity)
                } else if let image = selectedUIImage {
                    EditorView(
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        selectedUIImage: $selectedUIImage,
                        batchImages: $batchImages,
                        selectedColor: $selectedColor,
                        image: image,
                        onRenderedImage: showRenderedImage,
                        onBatchExportComplete: finishBatchExportAnimation
                    )
                    .transition(.opacity)
                } else if !batchImages.isEmpty {
                    EditorView(
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        selectedUIImage: $selectedUIImage,
                        batchImages: $batchImages,
                        selectedColor: $selectedColor,
                        image: batchImages[0],
                        isBatchMode: true,
                        onRenderedImage: showRenderedImage,
                        onBatchExportComplete: finishBatchExportAnimation
                    )
                    .transition(.opacity)
                } else {
                    SplashView(
                        selectedColor: selectedColor,
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        renderedImage: $renderedImage,
                        batchRenderedImages: $batchRenderedImages,
                        isBatchExportAnimationActive: isBatchExportAnimationActive,
                        renderedImageGeneration: renderedImageGeneration,
                        onRenderedImageDismissed: showNextRenderedImage,
                        onBatchRenderedImageDismissed: removeBatchRenderedImage
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.26), value: renderedImage != nil)
            .animation(.easeInOut(duration: 0.26), value: isBatchExportAnimationActive)
            .animation(.easeInOut(duration: 0.26), value: isBatchExportBackdropVisible)
            .animation(.easeInOut(duration: 0.26), value: selectedUIImage != nil)
            .animation(.easeInOut(duration: 0.26), value: batchImages.isEmpty)
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                guard let newValue else { return }
                
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        withAnimation {
                            selectedBatchItems = []
                            batchImages = []
                            selectedUIImage = image
                        }
                    }
                }
                
            }
        }
        .onChange(of: selectedBatchItems) { oldValue, newValue in
            Task {
                let pickedItems = Array(newValue.prefix(10))
                guard !pickedItems.isEmpty else {
                    await MainActor.run {
                        withAnimation {
                            batchImages = []
                        }
                    }
                    return
                }
                
                var loadedImages: [UIImage] = []
                
                for item in pickedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        loadedImages.append(image)
                    }
                }
                
                await MainActor.run {
                    withAnimation {
                        selectedItem = nil
                        if loadedImages.count == 1 {
                            selectedBatchItems = []
                            selectedUIImage = loadedImages[0]
                            batchImages = []
                        } else {
                            selectedUIImage = nil
                            batchImages = loadedImages
                        }
                    }
                }
            }
        }
    }
    
    private func showRenderedImage(_ image: UIImage, isBatch: Bool = false, showsConfetti: Bool = false) {
        if isBatch {
            withAnimation(.easeInOut(duration: 0.26)) {
                isBatchExportComplete = false
                isBatchExportBackdropVisible = true
                batchRenderedImages.append(RenderedExportImage(image: image, isFinal: showsConfetti))
            }
            startBatchExportAnimationAfterEditorFade()
            return
        }

        if showsConfetti {
            pendingReviewPrompt = true
        }

        withAnimation(.easeInOut(duration: 0.26)) {
            if renderedImage == nil {
                renderedImage = image
                renderedImageGeneration += 1
            } else {
                renderedImageQueue.append(image)
            }
        }
    }
    
    private func showNextRenderedImage() {
        guard renderedImage == nil, !renderedImageQueue.isEmpty else {
            if renderedImage == nil && pendingReviewPrompt {
                triggerReviewIfNeeded()
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.26)) {
            renderedImage = renderedImageQueue.removeFirst()
            renderedImageGeneration += 1
        }
    }
    
    private func finishBatchExportAnimation() {
        isBatchExportComplete = true
        finishBatchExportAnimationIfReady()
    }
    
    private func removeBatchRenderedImage(_ id: RenderedExportImage.ID) {
        batchRenderedImages.removeAll { $0.id == id }
        finishBatchExportAnimationIfReady()
    }
    
    private func finishBatchExportAnimationIfReady() {
        guard isBatchExportComplete, batchRenderedImages.isEmpty else { return }

        withAnimation(.easeInOut(duration: 0.26)) {
            isBatchExportAnimationActive = false
            isBatchExportBackdropVisible = false
            isBatchExportComplete = false
        }

        triggerReviewIfNeeded()
    }
    
    private func startBatchExportAnimationAfterEditorFade() {
        guard !isBatchExportAnimationActive else { return }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 280_000_000)

            guard isBatchExportBackdropVisible, !batchRenderedImages.isEmpty else { return }

            withAnimation(.easeInOut(duration: 0.26)) {
                isBatchExportAnimationActive = true
            }
        }
    }

    private func triggerReviewIfNeeded() {
        guard pendingReviewPrompt else { return }

        let currentCount = UserDefaults.standard.integer(forKey: "successful_exports_count")
        let hasPrompted = UserDefaults.standard.bool(forKey: "has_prompted_for_review")

        if currentCount >= 5 && !hasPrompted {
            requestReview()
            UserDefaults.standard.set(true, forKey: "has_prompted_for_review")
        }

        pendingReviewPrompt = false
    }
}

#Preview {
    ContentView()
}
