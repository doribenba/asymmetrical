//
//  border.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/29.
//

import SwiftUI
import UIKit

func createBorder(image: UIImage, width percentage: Float, color: Color) -> UIImage {
    
    let UiColor = UIColor(color)
    let originalSize = image.size
    
    let base = min(originalSize.width, originalSize.height)
    let border = base * (CGFloat(percentage / 4) / 100)
    
    let newSize = CGSize(
        width: originalSize.width + border * 2,
        height: originalSize.height + border * 2
    )
    
    let format = UIGraphicsImageRendererFormat()
    format.scale = image.scale
    
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    
    return renderer.image { context in
        
        let rect = CGRect(origin: .zero, size: newSize)
        UiColor.setFill()
        context.fill(rect)
        
        let imageRect = CGRect(
            x: border,
            y: border,
            width: originalSize.width,
            height: originalSize.height
        )
        
        image.draw(in: imageRect)
    }
}
