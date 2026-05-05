//
//  List.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import AppKit
import ArgumentParser
import Files

extension Duotone {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "List all presets.")

        mutating func run() throws {
            let presets = try Duotone.loadPresets()
            for preset in presets {
                var line = "Name: \(preset.name) - Light: \(preset.light), Dark: \(preset.dark)"
                line += ", Contrast: \(preset.contrast), Blend: \(preset.blend)"
                if let description = preset.description, !description.isEmpty {
                    line += " — \(description)"
                }
                print(line)
            }
        }
    }
}
