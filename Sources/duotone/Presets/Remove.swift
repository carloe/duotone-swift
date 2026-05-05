//
//  Remove.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import AppKit
import ArgumentParser
import Files

extension Duotone {
    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Remove a preset.")

        @Option(name: .long, help: "The name of the preset")
        var preset: String

        mutating func run() throws {
            let presets = try Duotone.loadPresets()
            let filtered = try removingPreset(from: presets)
            try Duotone.savePresets(filtered)
            print("Removed '\(preset)'")
        }

        func removingPreset(from existing: [Preset]) throws -> [Preset] {
            let filtered = existing.filter { $0.name != preset }
            if existing.count == filtered.count {
                throw ValidationError("No existing preset with name '\(preset)' found")
            }
            return filtered
        }
    }
}
