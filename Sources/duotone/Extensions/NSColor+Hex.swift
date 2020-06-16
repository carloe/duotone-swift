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

extension NSColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) throws {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        if hexFormatted.count != 6 {
            throw ColorHexError.invalidFormat
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    var hexString: String {
        let rgb:Int = (Int)(self.redValue*255)<<16 | (Int)(self.greenValue*255)<<8 | (Int)(self.blueValue*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension NSColor {
    var redValue: CGFloat { return CIColor(color: self)!.red }
    var greenValue: CGFloat { return CIColor(color: self)!.green }
    var blueValue: CGFloat { return CIColor(color: self)!.blue }
    var alphaValue: CGFloat { return CIColor(color: self)!.alpha }
}


