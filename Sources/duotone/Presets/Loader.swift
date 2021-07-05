//
//  Loader.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import ArgumentParser
import Files
import Foundation

private let presetLocation = "~/.duotone"

extension Duotone {
    static func loadPresets() throws -> [Preset] {
        guard let file = try? File(path: presetLocation) else {
            return [Preset]()
        }
        guard let data = try? Data(contentsOf: file.url) else {
            throw ValidationError("Could not read the preset file: \(presetLocation).")
        }
        return try JSONDecoder().decode([Preset].self, from: data)
    }

    static func savePresets(_ presets: [Preset]) throws {
        let file = try File(path: presetLocation)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(presets)
        try file.write(data)
    }
}
