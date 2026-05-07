//
//  invert.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/28.
//

import SwiftUI

extension Color {
    func inverted() -> Color {
            let uiColor = UIColor(self)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0

            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

            return Color(

                red: 1.0 - r,
                green: 1.0 - g,
                blue: 1.0 - b,
                opacity: a

            )
        }
    
    var isdark: Bool {

        let uiColor = UIColor(self)

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance < 0.5
    }
}

