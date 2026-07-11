//
//  headerView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/30.
//

import SwiftUI
import PhotosUI
import Photos
import LinkPresentation

struct AspectRatioOption: Identifiable, Equatable {
    let id: String
    let title: String
    let symbolName: String
    let ratio: CGFloat?
    
    var isAsymmetrical: Bool {
        id == "asymmetrical"
    }
    
    var isDouble: Bool {
        id == "double"
    }
    
    static let original = AspectRatioOption(
        id: "original",
        title: "EVEN",
        symbolName: "photo",
        ratio: nil
    )
    
    static let all: [AspectRatioOption] = [
        .original,
        AspectRatioOption(id: "instagram", title: "INSTAGRAM", symbolName: "rectangle.portrait", ratio: 4 / 5),
        AspectRatioOption(id: "square", title: "SQUARE", symbolName: "square", ratio: 1),
        AspectRatioOption(id: "asymmetrical", title: "ASYMMETRICAL", symbolName: "skew", ratio: nil),
        AspectRatioOption(id: "double", title: "DOUBLE", symbolName: "inset.filled.square.dashed", ratio: nil),
        AspectRatioOption(id: "story", title: "STORY", symbolName: "rectangle.portrait", ratio: 9 / 16)
    ]
    
    static let standard: [AspectRatioOption] = [
        AspectRatioOption(id: "four-three", title: "4:3", symbolName: "rectangle", ratio: 4 / 3),
        AspectRatioOption(id: "three-four", title: "3:4", symbolName: "rectangle.portrait", ratio: 3 / 4),
        AspectRatioOption(id: "three-two", title: "3:2", symbolName: "rectangle", ratio: 3 / 2),
        AspectRatioOption(id: "two-three", title: "2:3", symbolName: "rectangle.portrait", ratio: 2 / 3),
        AspectRatioOption(id: "four-five", title: "5:4", symbolName: "rectangle.portrait", ratio: 5 / 4),
        AspectRatioOption(id: "sixteen-nine", title: "16:9", symbolName: "rectangle", ratio: 16 / 9)
    ]
}

enum DoubleBorderLayer {
    case outer
    case inner
}

struct HeaderView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedBatchItems: [PhotosPickerItem]
    @Binding var selectedUIImage: UIImage?
    @Binding var batchImages: [UIImage]
    @Binding var selectedAspectRatio: AspectRatioOption

    @Environment(\.requestReview) var requestReview

    @State private var shareItem: ShareItem?
    
    let selectedColor: Color
    let borderSize: Float
    let doubleOuterColor: Color
    let doubleOuterBorderSize: Float
    let doubleInnerColor: Color
    let doubleInnerBorderSize: Float
    let overlayText: String
    let image: UIImage
    let isBatchMode: Bool
    let onRenderedImage: (UIImage, Bool, Bool) -> Void
    let onBatchExportComplete: () -> Void
    
    // MARK: - Removable Export Completion State
    @State private var exportErrorMessage: String? = nil
    @State private var isExporting: Bool = false
    
    var body: some View {
        VStack{
            HStack{
                Button {
                    withAnimation {
                        closeEditor()
                    }
                    if isBatchMode {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                batchImages = []
                            }
                        }
                } label: {
                    Image(systemName: "x.circle")
                        .tint(selectedColor)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Spacer()
                
                if !isBatchMode {
                    Button {
                        withAnimation{
                            shareImage()
                        }
                    } label: {
                        Text("SHARE")
                            .fontWeight(.bold)
                            .monospaced()
                            .tint(selectedColor)
                    }
                    .disabled(isExporting)
                    
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(.secondary.opacity(0.55))
                    .frame(width: 2, height: 18)
                    .padding(.horizontal, 3)
                }
                
                Button {
                    if isBatchMode {
                        withAnimation{
                            exportAllImages()
                        }
                    } else {
                        withAnimation{
                            exportImage()
                        }
                    }
                } label: {
                    Text(isBatchMode ? "DONE/EXPORT ALL" : "DONE/EXPORT")
                        .fontWeight(.bold)
                        .monospaced()
                        .tint(selectedColor)
                }
                .disabled(isExporting)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    aspectRatioButtons(AspectRatioOption.all)
                    
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .fill(.secondary.opacity(0.55))
                        .frame(width: 2, height: 18)
                        .padding(.horizontal, 3)
                    
                    aspectRatioButtons(AspectRatioOption.standard)
                }
                .padding(.horizontal, 24)
            }
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.08),
                        .init(color: .black, location: 0.92),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .padding(.horizontal, -24)
            .padding(.top, 6)
        }
        .alert("EXPORT FAILED", isPresented: Binding(
            get: { exportErrorMessage != nil },
            set: { if !$0 { exportErrorMessage = nil } }
        )) {
            Button("ALRIGHT", role: .cancel) {}
        } message: {
            //Text(exportErrorMessage ?? "The image could not be saved.")
            Text("The application doesn't have your permission to save images. Go fix it.")
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [ImageActivityItemSource(image: item.image)])
        }
    }
    
    @ViewBuilder
    private func aspectRatioButtons(_ options: [AspectRatioOption]) -> some View {
        ForEach(options) { option in
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    selectedAspectRatio = option
                }
            } label: {
                Label(option.title, systemImage: option.symbolName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospaced()
                    .frame(height: 18)
                    .foregroundStyle(selectedAspectRatio == option ? selectedColor : .secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(.secondary.opacity(selectedAspectRatio == option ? 0.20 : 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Removable Export Completion Handling
    private func closeEditor() {
        if isBatchMode {
            selectedBatchItems = []
        } else {
            selectedItem = nil
            selectedUIImage = nil
        }
    }
    
    private func shareImage() {
        exportErrorMessage = nil
        
        let borderedImage = createBorder(
            image: image,
            width: borderSize,
            color: selectedColor,
            aspectRatio: selectedAspectRatio.ratio,
            isAsymmetrical: selectedAspectRatio.isAsymmetrical,
            isDouble: selectedAspectRatio.isDouble,
            doubleOuterWidth: doubleOuterBorderSize,
            doubleOuterColor: doubleOuterColor,
            doubleInnerWidth: doubleInnerBorderSize,
            doubleInnerColor: doubleInnerColor,
            overlayText: overlayText
        )
        
        let share = borderedImage
        shareItem = ShareItem(image: share)
    }
    
    private func exportImage() {
        isExporting = true
        exportErrorMessage = nil
        
        let borderedImage = createBorder(
            image: image,
            width: borderSize,
            color: selectedColor,
            aspectRatio: selectedAspectRatio.ratio,
            isAsymmetrical: selectedAspectRatio.isAsymmetrical,
            isDouble: selectedAspectRatio.isDouble,
            doubleOuterWidth: doubleOuterBorderSize,
            doubleOuterColor: doubleOuterColor,
            doubleInnerWidth: doubleInnerBorderSize,
            doubleInnerColor: doubleInnerColor,
            overlayText: overlayText
        )
        
        Task {
            do {
                try await saveToPhotoLibrary(borderedImage)
                incrementExportCount()

                await MainActor.run {
                    isExporting = false
                    onRenderedImage(borderedImage, false, true)

                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedItem = nil
                        selectedUIImage = nil
                    }
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func exportAllImages() {
        guard !batchImages.isEmpty else { return }
        
        isExporting = true
        exportErrorMessage = nil
        let imagesToExport = batchImages
        
        Task {
            do {
                for imageIndex in imagesToExport.indices {
                    let image = imagesToExport[imageIndex]
                    let isLastImage = imageIndex == imagesToExport.index(before: imagesToExport.endIndex)
                    let borderedImage = createBorder(
                        image: image,
                        width: borderSize,
                        color: selectedColor,
                        aspectRatio: selectedAspectRatio.ratio,
                        isAsymmetrical: selectedAspectRatio.isAsymmetrical,
                        isDouble: selectedAspectRatio.isDouble,
                        doubleOuterWidth: doubleOuterBorderSize,
                        doubleOuterColor: doubleOuterColor,
                        doubleInnerWidth: doubleInnerBorderSize,
                        doubleInnerColor: doubleInnerColor,
                        overlayText: overlayText
                    )
                    
                    try await saveToPhotoLibrary(borderedImage)
//                    incrementExportCount()

                    await MainActor.run {
                        onRenderedImage(borderedImage, true, isLastImage)
                    }
                    
                    if !isLastImage {
                        try? await Task.sleep(nanoseconds: 620_000_000)
                    }
                }
                
                await MainActor.run {
                    isExporting = false
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedBatchItems = []
                        batchImages = []
                    }
                    onBatchExportComplete()
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportErrorMessage = error.localizedDescription
                    onBatchExportComplete()
                }
            }
        }
    }
    
    private func saveToPhotoLibrary(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? ExportError.photoLibrarySaveFailed)
                }
            }
        }
    }

    private func incrementExportCount() {
        let currentCount = UserDefaults.standard.integer(forKey: "successful_exports_count")
        UserDefaults.standard.set(currentCount + 1, forKey: "successful_exports_count")
    }
}

private enum ExportError: LocalizedError {
    case photoLibrarySaveFailed
    
    var errorDescription: String? {
        "The image could not be saved."
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private final class ImageActivityItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "Share Image"
        metadata.imageProvider = NSItemProvider(object: image)
        metadata.iconProvider = NSItemProvider(object: image)
        return metadata
    }
}
