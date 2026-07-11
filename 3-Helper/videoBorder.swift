////
////  videoBorder.swift
////  borderControl
////
////  Created by Dorian Benbassat on 2026/6/17.
////
//
//import Foundation
//import AVFoundation
//import CoreGraphics
//
//func createVideoBorder(
//    videoURL: URL,
//    width percentage: Float,
//    color: CGColor,
//    completion: @escaping (Result<URL, Error>) -> Void
//) {
//    // Create an output URL in the temporary directory
//    let outputURL = FileManager.default.temporaryDirectory
//        .appendingPathComponent(UUID().uuidString)
//        .appendingPathExtension("mov")
//
//    // Load the video asset
//    let asset = AVAsset(url: videoURL)
//
//    // Load asset properties asynchronously
//    Task {
//        do {
//            // Check if the asset is compatible
//            let isExportable = try await asset.load(.isExportable)
//            guard isExportable else {
//                throw NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Video is not exportable"])
//            }
//
//            // Get the video track
//            let videoTracks = try await asset.loadTracks(withMediaType: .video)
//            guard let videoTrack = videoTracks.first else {
//                throw NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video track found"])
//            }
//
//            // Create composition
//            let composition = AVMutableComposition()
//
//            // Add video track to composition
//            let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
//            do {
//                try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: try await asset.load(.duration)), of: videoTrack, at: .zero)
//            } catch {
//                throw error
//            }
//
//            // Get video properties from the track
//            let naturalSize = try await videoTrack.load(.naturalSize)
//            let preferredTransform = try await videoTrack.load(.preferredTransform)
//
//            // Calculate border size
//            let base = min(naturalSize.width, naturalSize.height)
//            let borderSize = base * (CGFloat(percentage / 4) / 100)
//
//            // Calculate final video size with border
//            let finalWidth = naturalSize.width + borderSize * 2
//            let finalHeight = naturalSize.height + borderSize * 2
//            let finalSize = CGSize(width: finalWidth, height: finalHeight)
//
//            // Create video composition instructions
//            let instruction = AVMutableVideoCompositionInstruction()
//            instruction.timeRange = CMTimeRangeMake(start: .zero, duration: try await asset.load(.duration))
//
//            // Create layer instruction
//            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
//
//            // Set transform to compensate for video orientation
//            layerInstruction.setTransform(preferredTransform, at: .zero)
//
//            instruction.layerInstructions = [layerInstruction]
//
//            // Create video composition
//            let videoComposition = AVMutableVideoComposition()
//            videoComposition.renderSize = finalSize
//            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
//            videoComposition.renderScale = 1.0
//            videoComposition.instructions = [instruction]
//
//            // Create overlay to draw border
//            let parentLayer = CALayer()
//            let videoLayer = CALayer()
//
//            parentLayer.frame = CGRect(origin: .zero, size: finalSize)
//            videoLayer.frame = CGRect(x: borderSize, y: borderSize, width: naturalSize.width, height: naturalSize.height)
//
//            parentLayer.addSublayer(videoLayer)
//
//            // Create border layer
//            let borderLayer = CALayer()
//            borderLayer.backgroundColor = color
//            borderLayer.frame = CGRect(origin: .zero, size: finalSize)
//            parentLayer.insertSublayer(borderLayer, at: 0)
//
//            // Create animation tool for overlay
//            let animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
//            videoComposition.animationTool = animationTool
//
//            // Configure export
//            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
//                throw NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create export session"])
//            }
//
//            exportSession.outputURL = outputURL
//            exportSession.outputFileType = .mov
//            exportSession.shouldOptimizeForNetworkUse = true
//            exportSession.videoComposition = videoComposition
//
//            // Export video - avoid Sendable issues by not capturing exportSession
//            exportSession.exportAsynchronously {
//                DispatchQueue.main.async {
//                    switch exportSession.status {
//                    case .completed:
//                        completion(.success(outputURL))
//                    case .failed:
//                        completion(.failure(exportSession.error ?? NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export failed"])))
//                    case .cancelled:
//                        completion(.failure(NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"])))
//                    default:
//                        completion(.failure(NSError(domain: "VideoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown export error"])))
//                    }
//                }
//            }
//        } catch {
//            // Handle any errors that occurred during loading
//            completion(.failure(error))
//        }
//    }
//}
