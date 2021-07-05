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
    struct Add: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Add a presets.")

        @Option(name: .long, help: "The name of the preset")
        var name: String

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

            var contrast = (contrastOption != nil) ? CGFloat(contrastOption!) : 0.5
            if contrast > 1.0 { contrast = 1.0 } else if contrast < 0.0 { contrast = 0.0 }

            var blend = (blendOption != nil) ? CGFloat(blendOption!) : 1.0
            if blend > 1.0 { blend = 1.0 } else if blend < 0.0 { blend = 0.0 }

            let preset = Preset(name: name,
                                light: lightColor.toHexString(),
                                dark: darkColor.toHexString(),
                                contrast: contrast,
                                blend: blend,
                                description: description)

            var presets = try Duotone.loadPresets()
            let exists = presets.contains { $0.name == preset.name }
            if exists {
                throw "A preset with the name '\(preset.name)' already exists"
            }
            presets.append(preset)
            try Duotone.savePresets(presets)
            print("Added '\(preset.name)'")
        }
    }
}
