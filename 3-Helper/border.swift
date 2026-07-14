//
//  border.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/29.
//

import SwiftUI
import UIKit

struct AsymmetricalBorderLayout {
    static let top: CGFloat = 0.0153
    static let right: CGFloat = 0.0153
    static let left: CGFloat = 0.0269
    static let bottom: CGFloat = 0.0447
    
    static func padding(for imageSize: CGSize) -> UIEdgeInsets {
        let base = min(imageSize.width, imageSize.height)
        
        return UIEdgeInsets(
            top: base * top,
            left: base * left,
            bottom: base * bottom,
            right: base * right
        )
    }
    
    static func contentRect(for imageSize: CGSize) -> CGRect {
        let padding = padding(for: imageSize)
        
        return CGRect(
            x: padding.left,
            y: padding.top,
            width: imageSize.width,
            height: imageSize.height
        )
    }
    
    static func contentRect(for imageSize: CGSize, in size: CGSize) -> CGRect {
        let canvasSize = canvasSize(for: imageSize)
        let contentRect = contentRect(for: imageSize)
        let scale = min(size.width / canvasSize.width, size.height / canvasSize.height)
        
        return CGRect(
            x: contentRect.minX * scale,
            y: contentRect.minY * scale,
            width: contentRect.width * scale,
            height: contentRect.height * scale
        )
    }
    
    static func canvasSize(for imageSize: CGSize) -> CGSize {
        let padding = padding(for: imageSize)
        
        return CGSize(
            width: imageSize.width + padding.left + padding.right,
            height: imageSize.height + padding.top + padding.bottom
        )
    }
}

func createBorder(
    image: UIImage,
    width percentage: Float,
    color: Color,
    aspectRatio: CGFloat? = nil,
    isAsymmetrical: Bool = false,
    isDouble: Bool = false,
    doubleOuterWidth: Float = 20,
    doubleOuterColor: Color = .white,
    doubleInnerWidth: Float = 20,
    doubleInnerColor: Color = .white,
    overlayText: String = ""
) -> UIImage {
    if isDouble {
        return createDoubleBorder(
            image: image,
            outerWidth: doubleOuterWidth,
            outerColor: doubleOuterColor,
            innerWidth: doubleInnerWidth,
            innerColor: doubleInnerColor
        )
    }
    
    if isAsymmetrical {
        return createAsymmetricalBorder(
            image: image,
            color: color,
            overlayText: overlayText
        )
    }
    
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

private func createDoubleBorder(
    image: UIImage,
    outerWidth: Float,
    outerColor: Color,
    innerWidth: Float,
    innerColor: Color
) -> UIImage {
    let innerImage = createBorder(
        image: image,
        width: calculateBorder(border: innerWidth),
        color: innerColor
    )
    
    return createBorder(
        image: innerImage,
        width: calculateBorder(border: outerWidth),
        color: outerColor
    )
}

private func createAsymmetricalBorder(image: UIImage, color: Color, overlayText: String) -> UIImage {
    let uiColor = UIColor(color)
    let originalSize = image.size
    let newSize = AsymmetricalBorderLayout.canvasSize(for: originalSize)
    
    let format = UIGraphicsImageRendererFormat()
    format.scale = image.scale
    format.opaque = true
    
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    
    return renderer.image { context in
        let rect = CGRect(origin: .zero, size: newSize)
        uiColor.setFill()
        context.fill(rect)
        
        let contentRect = AsymmetricalBorderLayout.contentRect(for: originalSize)
        image.draw(in: contentRect)
        
        let trimmedOverlayText = overlayText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOverlayText.isEmpty else { return }
        
        let bottomRect = CGRect(
            x: contentRect.minX,
            y: contentRect.maxY,
            width: contentRect.width,
            height: newSize.height - contentRect.maxY
        )
        let fontSize = max(8, bottomRect.height * 0.78)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: uiColor.isDark ? UIColor.white : UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        let textRect = bottomRect.insetBy(dx: 0, dy: max(0, (bottomRect.height - fontSize) / 2))
        
        trimmedOverlayText.draw(with: textRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: attributes, context: nil)
    }
}

private extension UIColor {
    var isDark: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance < 0.5
    }
}

func calculateBorder(border: Float) -> Float {
    switch border {
    case 5:
        return 5
    case 10:
        return 7
    case 15:
        return 10
    case 20:
        return 15
    case 25:
        return 22
    case 30:
        return 30
    case 35:
        return 35
    case 40:
        return 40
    case 45:
        return 50
    case 50:
        return 55
    case 55:
        return 60
    case 60:
        return 67
    case 65:
        return 72
    case 70:
        return 77
    case 75:
        return 82
    case 80:
        return 90
    case 85:
        return 100
    case 90:
        return 110
    case 95:
        return 120
    case 100:
        return 135
    default:
        return 0
    }
}
