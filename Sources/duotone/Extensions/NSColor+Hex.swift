//
//  NSColor+Hex.swift
//  ArgumentParser
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

enum ColorHexError: Error {
    case invalidFormat
}

public extension NSColor {
    convenience init(hex: String) throws {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        var red, green, blue: CGFloat
        var alpha: CGFloat = 1.0

        if hexFormatted.count == 2 {
            let value = CGFloat(rgbValue & 0xFF) / 255.0
            red = value
            green = value
            blue = value
        } else if hexFormatted.count == 3 {
            red = CGFloat((rgbValue & 0xF00) >> 8) / 15.0
            green = CGFloat((rgbValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(rgbValue & 0x00F) / 15.0
        } else if hexFormatted.count == 4 {
            red =  CGFloat((rgbValue & 0xF000) >> 12) / 15
            green = CGFloat((rgbValue & 0x0F00) >> 8) / 15
            blue = CGFloat((rgbValue & 0x00F0) >> 4) / 15
            alpha = CGFloat(rgbValue & 0x000F) / 15
        } else if hexFormatted.count == 6 {
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        } else if hexFormatted.count == 8 {
            red =  CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        } else {
            throw ColorHexError.invalidFormat
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension NSColor {
    var redValue: CGFloat { return CIColor(color: self)?.red ?? 0.0 }
    var greenValue: CGFloat { return CIColor(color: self)?.green ?? 0.0 }
    var blueValue: CGFloat { return CIColor(color: self)?.blue ?? 0.0 }
    var alphaValue: CGFloat { return CIColor(color: self)?.alpha ?? 0.0 }
}
