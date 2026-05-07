//
//  headerView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/30.
//

import SwiftUI
import PhotosUI
import Photos

struct HeaderView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedUIImage: UIImage?
    
    let selectedColor: Color
    let borderSize: Float
    let image: UIImage
    
    @Binding var renderedImage: UIImage?
    
    @State private var showPicker = false
    @State private var selectedOption = "Option 1"
    
    // MARK: - Removable Export Completion State
    @State private var exportErrorMessage: String? = nil
    @State private var isExporting: Bool = false
    
    let options = ["CANCEL", "SHARE"]
    
    var body: some View {
        VStack{
            HStack{
                Button {
                    withAnimation {
                        selectedItem = nil
                        selectedUIImage = nil
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .tint(selectedColor)
                }
                Spacer()
                Button {
                    exportImage()
                } label: {
                    Text("DONE/EXPORT")
                        .monospaced()
                        .tint(selectedColor)
                }
                .disabled(isExporting)
            }
            //            ScrollView(.horizontal, showsIndicators: false) {
            //                HStack(spacing: 12) {
            //                    ForEach(["ORIGINAL", "4/3", "3/4", "5/4", "4/5","3/2", "2/3", "1/1"], id: \.self) { title in
            //                                Button(title) {
            //                                    // something
            //                                }
            //                                .monospaced()
            //                            }
            //                }
            //                .padding(.horizontal, 10)
            //            }
        }
        .alert("Export failed", isPresented: Binding(
            get: { exportErrorMessage != nil },
            set: { if !$0 { exportErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportErrorMessage ?? "The image could not be saved.")
        }
    }
    
    // MARK: - Removable Export Completion Handling
    private func exportImage() {
        isExporting = true
        exportErrorMessage = nil
        
        let borderedImage = createBorder(
            image: image,
            width: borderSize,
            color: selectedColor
        )
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: borderedImage)
        } completionHandler: { success, error in
            Task { @MainActor in
                isExporting = false
                
                if success {
                    renderedImage = borderedImage
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedItem = nil
                        selectedUIImage = nil
                    }
                } else {
                    exportErrorMessage = error?.localizedDescription ?? "The image could not be saved."
                }
            }
        }
    }
}
