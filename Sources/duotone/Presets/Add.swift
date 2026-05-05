//
//  Add.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import AppKit
import ArgumentParser
import Files

extension Duotone {
    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Add a presets.")

        @Option(name: .long, help: "The name of the preset")
        var preset: String

        @Option(name: [.short, .customLong("light")], help: "The lightest color in hex")
        var lightHexOption: String

        @Option(name: [.short, .customLong("dark")], help: "The darkest color in hex")
        var darkHexOption: String

        @Option(name: [.short, .customLong("contrast")], help: "Contrast value between 0.0 and 1.0")
        var contrastOption: Float?

        @Option(name: [.short, .customLong("blend")], help: "Blend value between 0.0 and 1.0")
        var blendOption: Float?

        @Option(name: .long, help: "An optional description of the preset")
        var description: String?

        mutating func run() throws {
            let presets = try Duotone.loadPresets()
            let updated = try addingPreset(to: presets)
            try Duotone.savePresets(updated)
            print("Added '\(preset)'")
        }

        func addingPreset(to existing: [Preset]) throws -> [Preset] {
            let lightColor = try NSColor(hex: lightHexOption)
            let darkColor = try NSColor(hex: darkHexOption)

            let contrast = CGFloat(contrastOption ?? 0.5).clamped(to: 0...1)
            let blend = CGFloat(blendOption ?? 1.0).clamped(to: 0...1)

            let newPreset = Preset(name: preset,
                                   light: lightColor.toHexString(),
                                   dark: darkColor.toHexString(),
                                   contrast: contrast,
                                   blend: blend,
                                   description: description)

            if existing.contains(where: { $0.name == newPreset.name }) {
                throw ValidationError("A preset with the name '\(newPreset.name)' already exists")
            }
            return existing + [newPreset]
        }
    }
}
