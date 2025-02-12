//
//  Loader.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import ArgumentParser
import Files
import Foundation

extension Duotone {
    /// Handles loading and saving of presets
    enum PresetStorage {
        // MARK: - Constants
        
        private static let fileName = ".duotone"
        private static let presetLocation = "~/\(fileName)"
        
        // MARK: - Errors
        
        enum StorageError: LocalizedError {
            case readError(String)
            case writeError(String)
            
            var errorDescription: String? {
                switch self {
                case .readError(let path):
                    return "Could not read the preset file: \(path)"
                case .writeError(let path):
                    return "Could not write to preset file: \(path)"
                }
            }
        }
        
        // MARK: - Public Methods
        
        /// Loads presets from disk
        /// - Returns: Array of presets, empty if no preset file exists
        /// - Throws: StorageError if file exists but cannot be read
        static func loadPresets() throws -> [Preset] {
            guard let file = try? File(path: presetLocation) else {
                return []
            }
            
            do {
                let data = try Data(contentsOf: file.url)
                return try JSONDecoder().decode([Preset].self, from: data)
            } catch {
                throw StorageError.readError(presetLocation)
            }
        }
        
        /// Saves presets to disk
        /// - Parameter presets: Array of presets to save
        /// - Throws: StorageError if writing fails
        static func savePresets(_ presets: [Preset]) throws {
            do {
                let file = try File(path: presetLocation)
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                
                let data = try encoder.encode(presets)
                try file.write(data)
            } catch {
                throw StorageError.writeError(presetLocation)
            }
        }
    }
}
