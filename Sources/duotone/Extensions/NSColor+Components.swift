//
//  NSColor+Components.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

extension NSColor {
    var redValue: CGFloat { return CIColor(color: self)!.red }
    var greenValue: CGFloat { return CIColor(color: self)!.green }
    var blueValue: CGFloat { return CIColor(color: self)!.blue }
    var alphaValue: CGFloat { return CIColor(color: self)!.alpha }
}
