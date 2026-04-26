//
//  Loader.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import ArgumentParser
import Files
import Foundation

private let defaultPresetLocation = "~/.duotone"

extension Duotone {
    static func loadPresets() throws -> [Preset] {
        try loadPresets(from: defaultPresetLocation)
    }

    static func savePresets(_ presets: [Preset]) throws {
        try savePresets(presets, to: defaultPresetLocation)
    }

    static func loadPresets(from path: String) throws -> [Preset] {
        let resolved = NSString(string: path).expandingTildeInPath
        guard let file = try? File(path: resolved) else {
            return []
        }
        guard let data = try? Data(contentsOf: file.url) else {
            throw ValidationError("Could not read the preset file: \(path).")
        }
        return try JSONDecoder().decode([Preset].self, from: data)
    }

    static func savePresets(_ presets: [Preset], to path: String) throws {
        let resolved = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: resolved)
        let parentFolder = try Folder(path: url.deletingLastPathComponent().path)
        let file = try parentFolder.createFileIfNeeded(at: url.lastPathComponent)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(presets)
        try file.write(data)
    }
}
