//
//  Preset.swift
//  ArgumentParser
//
//  Created by Carlo Eugster on 05.07.21.
//

import Foundation

/// Represents a color preset configuration for duotone image processing
struct Preset: Codable, Equatable {
    // MARK: - Constants
    
    private enum Constants {
        static let defaultContrast: CGFloat = 0.5
        static let defaultBlend: CGFloat = 1.0
        static let minimumNameLength = 2
    }
    
    // MARK: - Properties
    
    /// Unique identifier for the preset
    let name: String
    
    /// Hex color string for the lightest color
    let light: String
    
    /// Hex color string for the darkest color
    let dark: String
    
    /// Contrast value between 0.0 and 1.0
    let contrast: CGFloat
    
    /// Blend value between 0.0 and 1.0
    let blend: CGFloat
    
    /// Optional description of the preset
    let presetDescription: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, light, dark, contrast, blend
        case presetDescription = "description"
    }
    
    // MARK: - Initialization
    
    /// Creates a new preset with the specified parameters
    /// - Parameters:
    ///   - name: Unique identifier for the preset
    ///   - light: Hex color string for the lightest color
    ///   - dark: Hex color string for the darkest color
    ///   - contrast: Contrast value between 0.0 and 1.0 (default: 0.5)
    ///   - blend: Blend value between 0.0 and 1.0 (default: 1.0)
    ///   - description: Optional description of the preset
    init(
        name: String,
        light: String,
        dark: String,
        contrast: CGFloat = Constants.defaultContrast,
        blend: CGFloat = Constants.defaultBlend,
        description: String? = nil
    ) {
        self.name = name
        self.light = light
        self.dark = dark
        self.contrast = min(max(contrast, 0.0), 1.0)
        self.blend = min(max(blend, 0.0), 1.0)
        self.presetDescription = description
    }
}

// MARK: - CustomStringConvertible

extension Preset: CustomStringConvertible {
    var description: String {
        var output = "Preset '\(name)' (light: \(light), dark: \(dark))"
        if let desc = presetDescription {
            output += " - \(desc)"
        }
        return output
    }
}
