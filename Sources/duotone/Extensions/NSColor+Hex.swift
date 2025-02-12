//
//  NSColor+Hex.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

/// Errors that can occur when working with hex color strings
enum ColorError: Error, Equatable {
    case invalidHexString
}

extension NSColor {
    /// Creates a color from a hex string (e.g., "#FF0000" or "FF0000" for RGB, "#FF0000FF" or "FF0000FF" for RGBA)
    /// - Parameter hex: The hex string to parse
    /// - Throws: ColorError if the string is invalid
    convenience init(hex: String) throws {
        // Remove hash if present
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        
        // Validate length (6 for RGB, 8 for RGBA)
        guard hexString.count == 6 || hexString.count == 8 else {
            throw ColorError.invalidHexString
        }
        
        // Validate characters
        let validCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        guard hexString.unicodeScalars.allSatisfy({ validCharacters.contains($0) }) else {
            throw ColorError.invalidHexString
        }
        
        // Convert to RGB(A) values
        var rgb: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgb) else {
            throw ColorError.invalidHexString
        }
        
        let hasAlpha = hexString.count == 8
        let divisor = CGFloat(255.0)
        
        if hasAlpha {
            let red = (CGFloat((rgb & 0xFF000000) >> 24) / divisor).rounded(to: 4)
            let green = (CGFloat((rgb & 0x00FF0000) >> 16) / divisor).rounded(to: 4)
            let blue = (CGFloat((rgb & 0x0000FF00) >> 8) / divisor).rounded(to: 4)
            let alpha = (CGFloat(rgb & 0x000000FF) / divisor).rounded(to: 4)
            self.init(srgbRed: red, green: green, blue: blue, alpha: alpha)
        } else {
            let red = (CGFloat((rgb & 0xFF0000) >> 16) / divisor).rounded(to: 4)
            let green = (CGFloat((rgb & 0x00FF00) >> 8) / divisor).rounded(to: 4)
            let blue = (CGFloat(rgb & 0x0000FF) / divisor).rounded(to: 4)
            self.init(srgbRed: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    /// Returns the hex string representation of the color (e.g., "#FF0000" or "#FF0000FF" if alpha < 1.0)
    var hexString: String {
        guard let rgbColor = usingColorSpace(.sRGB) else {
            return "#000000"
        }
        
        let red = Int(round(rgbColor.redComponent * 255.0))
        let green = Int(round(rgbColor.greenComponent * 255.0))
        let blue = Int(round(rgbColor.blueComponent * 255.0))
        let alpha = Int(round(rgbColor.alphaComponent * 255.0))
        
        return alpha < 255 
            ? String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
            : String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    /// The red component of the color (0.0-1.0)
    var redValue: CGFloat {
        guard let color = usingColorSpace(.sRGB) else { return 0 }
        return color.redComponent
    }
    
    /// The green component of the color (0.0-1.0)
    var greenValue: CGFloat {
        guard let color = usingColorSpace(.sRGB) else { return 0 }
        return color.greenComponent
    }
    
    /// The blue component of the color (0.0-1.0)
    var blueValue: CGFloat {
        guard let color = usingColorSpace(.sRGB) else { return 0 }
        return color.blueComponent
    }
    
    /// The alpha component of the color (0.0-1.0)
    var alphaValue: CGFloat {
        guard let color = usingColorSpace(.sRGB) else { return 1.0 }
        return color.alphaComponent
    }
}

private extension CGFloat {
    /// Rounds the float to a specific number of decimal places
    func rounded(to places: Int) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(places))
        return (self * multiplier).rounded() / multiplier
    }
}
