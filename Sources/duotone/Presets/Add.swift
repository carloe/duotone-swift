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
            let lightColor = try NSColor(hex: lightHexOption)
            let darkColor = try NSColor(hex: darkHexOption)

            let contrast = CGFloat(contrastOption ?? 0.5).clamped(to: 0...1)
            let blend = CGFloat(blendOption ?? 1.0).clamped(to: 0...1)

            let preset = Preset(name: preset,
                                light: lightColor.toHexString(),
                                dark: darkColor.toHexString(),
                                contrast: contrast,
                                blend: blend,
                                description: description)

            var presets = try Duotone.loadPresets()
            let exists = presets.contains { $0.name == preset.name }
            if exists {
                throw ValidationError("A preset with the name '\(preset.name)' already exists")
            }
            presets.append(preset)
            try Duotone.savePresets(presets)
            print("Added '\(preset.name)'")
        }
    }
}
