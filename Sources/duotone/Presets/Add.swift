//
//  Add.swift
//  ArgumentParser
//
//  Created by Carlo Eugster on 05.07.21.
//

import AppKit
import ArgumentParser
import Files

extension Duotone {
    /// Command to add a new preset to the duotone configuration
    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Add a preset.",
            discussion: "Adds a new color preset with specified light and dark colors, contrast, and blend values."
        )
        
        // MARK: - Error Types
        
        enum AddError: LocalizedError {
            case presetAlreadyExists(String)
            case invalidHexValue(String)
            
            var errorDescription: String? {
                switch self {
                case .presetAlreadyExists(let name):
                    return "A preset with the name '\(name)' already exists"
                case .invalidHexValue(let hex):
                    return "Invalid hex color value: \(hex)"
                }
            }
        }
        
        // MARK: - Properties
        
        @Option(name: .long, help: "The name of the preset")
        var preset: String
        
        @Option(name: [.short, .customLong("light")], help: "The lightest color in hex format (e.g., #FFFFFF)")
        var lightHexOption: String
        
        @Option(name: [.short, .customLong("dark")], help: "The darkest color in hex format (e.g., #000000)")
        var darkHexOption: String
        
        @Option(
            name: [.short, .customLong("contrast")],
            help: "Contrast value between 0.0 and 1.0",
            transform: Add.parseFloat
        )
        var contrastOption: Float?
        
        @Option(
            name: [.short, .customLong("blend")],
            help: "Blend value between 0.0 and 1.0",
            transform: Add.parseFloat
        )
        var blendOption: Float?
        
        @Option(name: .long, help: "An optional description of the preset")
        var description: String?
        
        // MARK: - Methods
        
        private static func parseFloat(_ string: String) throws -> Float {
            guard let value = Float(string) else {
                throw ValidationError("Invalid float value: \(string)")
            }
            return validateRange(value)
        }
        
        private static func validateRange(_ value: Float) -> Float {
            min(max(value, 0.0), 1.0)
        }
        
        private func validateColors() throws -> (light: NSColor, dark: NSColor) {
            guard let lightColor = try? NSColor(hex: lightHexOption) else {
                throw AddError.invalidHexValue(lightHexOption)
            }
            
            guard let darkColor = try? NSColor(hex: darkHexOption) else {
                throw AddError.invalidHexValue(darkHexOption)
            }
            
            return (lightColor, darkColor)
        }
        
        private func createPreset(lightColor: NSColor, darkColor: NSColor) -> Preset {
            let contrast = CGFloat(contrastOption ?? 0.5)
            let blend = CGFloat(blendOption ?? 1.0)
            
            return Preset(
                name: preset,
                light: lightColor.toHexString(),
                dark: darkColor.toHexString(),
                contrast: contrast,
                blend: blend,
                description: description
            )
        }
        
        mutating func run() throws {
            // Validate colors
            let (lightColor, darkColor) = try validateColors()
            
            // Create new preset
            let newPreset = createPreset(lightColor: lightColor, darkColor: darkColor)
            
            // Load and validate existing presets
            var presets = try PresetStorage.loadPresets()
            guard !presets.contains(where: { $0.name == newPreset.name }) else {
                throw AddError.presetAlreadyExists(newPreset.name)
            }
            
            // Save updated presets
            presets.append(newPreset)
            try PresetStorage.savePresets(presets)
            
            print("Added '\(newPreset.name)'")
        }
    }
}
