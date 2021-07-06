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
        static var configuration = CommandConfiguration(abstract: "List all presets.")

        mutating func run() throws {
            let presets = try Duotone.loadPresets()
            for preset in presets {
                print("Name: \(preset.name) - Light: \(preset.light), Dark: \(preset.dark), Contrast: \(preset.contrast), Blend: \(preset.blend)")
            }
        }
    }
}
