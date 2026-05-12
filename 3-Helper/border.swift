//
//  border.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/29.
//

import SwiftUI
import UIKit

func createBorder(image: UIImage, width percentage: Float, color: Color, aspectRatio: CGFloat? = nil) -> UIImage {
    
    let UiColor = UIColor(color)
    let originalSize = image.size
    
    let base = min(originalSize.width, originalSize.height)
    let border = base * (CGFloat(percentage / 4) / 100)
    
    let evenBorderSize = CGSize(
        width: originalSize.width + border * 2,
        height: originalSize.height + border * 2
    )
    
    let newSize: CGSize
    if let aspectRatio {
        let evenBorderAspectRatio = evenBorderSize.width / evenBorderSize.height
        
        if aspectRatio > evenBorderAspectRatio {
            newSize = CGSize(
                width: evenBorderSize.height * aspectRatio,
                height: evenBorderSize.height
            )
        } else {
            newSize = CGSize(
                width: evenBorderSize.width,
                height: evenBorderSize.width / aspectRatio
            )
        }
    } else {
        newSize = evenBorderSize
    }
    
    let format = UIGraphicsImageRendererFormat()
    format.scale = image.scale
    format.opaque = true
    
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    
    return renderer.image { context in
        
        let rect = CGRect(origin: .zero, size: newSize)
        UiColor.setFill()
        context.fill(rect)
        
        let imageRect = CGRect(
            x: (newSize.width - originalSize.width) / 2,
            y: (newSize.height - originalSize.height) / 2,
            width: originalSize.width,
            height: originalSize.height
        )
        
        image.draw(in: imageRect)
    }
}
