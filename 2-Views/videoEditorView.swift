////
////  videoEditorView.swift
////  borderControl
////
////  Created by Dorian Benbassat on 2026/6/17.
////
//
//import SwiftUI
//import PhotosUI
//import UIKit
//import AVFoundation
//
//struct VideoEditorView: View {
//    @Binding var selectedItem: PhotosPickerItem?
//    @Binding var selectedVideoURL: URL?
//    @Binding var isVideoMode: Bool
//    @Binding var selectedColor: Color
//    let videoURL: URL
//    let onRenderedImage: (UIImage, Bool, Bool) -> Void
//    let onBatchExportComplete: () -> Void
//
//    @State private var processedVideoURL: URL? // New: for processed video during export
//    @State private var isExporting: Bool = false // New: track export state
//    @State private var exportProgress: Double = 0 // New: export progress
//    @State private var exportError: String? = nil // New: track export errors
//
//    @State private var borderSize: Float = 20
//    @State private var isBorderSizeOverlayVisible = false
//    @State private var borderSizeOverlayGeneration = 0
//
//    var body: some View {
//        VStack(alignment: .leading){
//            // Simplified header for video mode - no share button, no double/asymmetrical controls
//            VStack {
//                HStack{
//                    Button {
//                        withAnimation {
//                            // Reset video selection
//                            selectedItem = nil
//                            selectedVideoURL = nil
//                            isVideoMode = false
//                        }
//                    } label: {
//                        Image(systemName: "x.circle")
//                            .tint(selectedColor)
//                            .font(.system(size: 16, weight: .bold))
//                    }
//
//                    Spacer()
//
//                    // Export/Done button for video
//                    Button {
//                        exportVideo()
//                    } label: {
//                        Text(isExporting ? "EXPORTING..." : "DONE/EXPORT")
//                            .fontWeight(.bold)
//                            .monospaced()
//                            .tint(selectedColor)
//                    }
//                    .disabled(isExporting || selectedVideoURL == nil)
//                }
//                .padding(.horizontal)
//
//                Divider()
//                    .background(.secondary.opacity(0.5))
//                    .padding(.vertical, 6)
//            }
//
//            ZStack {
//                // Video preview placeholder
//                Rectangle()
//                    .fill(.secondary.opacity(0.2))
//                    .overlay(
//                        VStack {
//                            Text("VIDEO PREVIEW")
//                                .font(.title2)
//                                .foregroundColor(.secondary)
//                            Text("Border size: \(Int(borderSize))")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                    )
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                if isBorderSizeOverlayVisible {
//                    Text("\(Int(borderSize))")
//                        .font(.system(size: 50, weight: .black, design: .monospaced))
//                        .foregroundStyle(.white)
//                        .blendMode(.difference)
//                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
//                }
//            }
//            .padding(.top, 13)
//            .padding(.bottom, 9)
//            .animation(.easeInOut(duration: 0.1), value: selectedColor)
//            .onChange(of: borderSize) { _, _ in
//                showBorderSizeOverlay()
//            }
//
//            // Controls for video mode - simplified (just border size and color)
//            VStack(spacing: 16) {
//                ColorPicker("BORDER COLOR ->", selection: $selectedColor)
//                    .foregroundStyle(selectedColor)
//                    .monospaced()
//                    .fontWeight(.bold)
//                    .padding(.bottom, 8)
//
//                HStack{
//                    Slider(value: $borderSize, in: 0...100, step: 5)
//                        .tint(Color.darkBlue)
//                    Text(" WIDTH")
//                        .monospaced()
//                        .fontWeight(.bold)
//                        .foregroundStyle(selectedColor)
//                }
//            }
//            .padding()
//        }
//        .padding(40)
//        .overlay(
//            // Export progress overlay
//            ZStack {
//                if isExporting {
//                    Color.black.opacity(0.5)
//                        .ignoresSafeArea()
//
//                    VStack(spacing: 20) {
//                        Text("EXPORTING...")
//                            .font(.headline)
//                            .foregroundColor(.white)
//
//                        ProgressView(value: exportProgress)
//                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
//                            .frame(width: 200)
//
//                        if let error = exportError {
//                            Text("Error: \(error)")
//                                .font(.caption)
//                                .foregroundColor(.red)
//                                .lineLimit(2)
//                                .multilineTextAlignment(.center)
//                        } else {
//                            Text("SAVED!")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.green)
//                                .opacity(exportProgress >= 1.0 ? 1.0 : 0.0)
//                        }
//                    }
//                }
//            }
//        )
//    }
//
//    private func showBorderSizeOverlay() {
//        borderSizeOverlayGeneration += 1
//        let currentGeneration = borderSizeOverlayGeneration
//
//        withAnimation(.easeOut(duration: 0.12)) {
//            isBorderSizeOverlayVisible = true
//        }
//
//        Task { @MainActor in
//            try? await Task.sleep(nanoseconds: 650_000_000)
//
//            if borderSizeOverlayGeneration == currentGeneration {
//                withAnimation(.easeOut(duration: 0.2)) {
//                    isBorderSizeOverlayVisible = false
//                }
//            }
//        }
//    }
//
//    // New: Export video function
//    private func exportVideo() {
//        guard let videoURL = selectedVideoURL else { return }
//
//        isExporting = true
//        exportProgress = 0
//        exportError = nil
//
//        Task {
//            do {
//                // Simulate progress updates for UI feedback
//                let progressTask = Task {
//                    for i in 1...10 {
//                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds each
//                        if !Task.isCancelled {
//                            exportProgress = Double(i) / 10.0
//                        }
//                    }
//                }
//
//                // Process the video with actual border
//                processedVideoURL = try await createVideoBorder(
//                    videoURL: videoURL,
//                    width: borderSize,
//                    color: UIColor(selectedColor).cgColor
//                )
//
//                // Cancel progress task
//                progressTask.cancel()
//
//                // Complete progress
//                exportProgress = 1.0
//
//                try? await Task.sleep(nanoseconds: 500_000_000) // Show SAVED! for 0.5 seconds
//
//                // Save to photo library and notify completion
//                if let processedURL = processedVideoURL {
//                    try await saveVideoToPhotoLibrary(processedURL)
//
//                    await MainActor.run {
//                        isExporting = false
//                        onRenderedImage(processedURL.thumbnailImage(), false, true)
//
//                        // Reset for next selection
//                        selectedItem = nil
//                        selectedVideoURL = nil
//                        isVideoMode = false
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    isExporting = false
//                    exportError = error.localizedDescription
//                    exportProgress = 0
//                }
//            }
//        }
//    }
//
//    // New: Save video to photo library
//    private func saveVideoToPhotoLibrary(_ videoURL: URL) async throws {
//        try await withCheckedThrowingContinuation { continuation in
//            PHPhotoLibrary.shared().performChanges {
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
//            } completionHandler: { success, error in
//                if success {
//                    continuation.resume()
//                } else {
//                    continuation.resume(throwing: error ?? ExportError.photoLibrarySaveFailed)
//                }
//            }
//        }
//    }
//}
//
//// Mock ExportError for compatibility
//private enum ExportError: LocalizedError {
//    case photoLibrarySaveFailed
//
//    var errorDescription: String? {
//        "The video could not be saved."
//    }
//}
//
//#Preview {
//    VideoEditorView(
//        selectedItem: .constant(nil),
//        selectedVideoURL: .constant(URL(fileURLWithPath: "")),
//        isVideoMode: .constant(true),
//        selectedColor: .constant(.white),
//        videoURL: URL(fileURLWithPath: ""),
//        onRenderedImage: { _, _, _ in },
//        onBatchExportComplete: {}
//    )
//}
