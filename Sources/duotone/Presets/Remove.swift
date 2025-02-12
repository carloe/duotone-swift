//
//  Remove.swift
//  duotone
//
//  Created by Carlo Eugster on 05.07.21.
//

import Foundation
import AppKit
import ArgumentParser
import Files

extension Duotone {
    /// Command to remove an existing preset from the configuration
    struct Remove: ParsableCommand {
        // MARK: - Configuration
        
        static let configuration = CommandConfiguration(
            abstract: "Remove a preset.",
            discussion: "Removes an existing preset from the configuration by name."
        )
        
        // MARK: - Error Types
        
        enum RemoveError: LocalizedError {
            case presetNotFound(String)
            
            var errorDescription: String? {
                switch self {
                case .presetNotFound(let name):
                    return "No existing preset with name '\(name)' found"
                }
            }
        }
        
        // MARK: - Properties
        
        @Option(
            name: .long,
            help: ArgumentHelp(
                "The name of the preset to remove",
                discussion: "Must match the name of an existing preset exactly"
            )
        )
        var preset: String
        
        // MARK: - Command Execution
        
        mutating func run() throws {
            let presets = try PresetStorage.loadPresets()
            let updatedPresets = try removePreset(named: preset, from: presets)
            try PresetStorage.savePresets(updatedPresets)
            
            print("✓ Successfully removed preset '\(preset)'")
        }
        
        // MARK: - Private Methods
        
        /// Removes a preset by name from the given array of presets
        /// - Parameters:
        ///   - name: Name of the preset to remove
        ///   - presets: Array of existing presets
        /// - Returns: Updated array with the preset removed
        /// - Throws: RemoveError if the preset is not found
        private func removePreset(named name: String, from presets: [Preset]) throws -> [Preset] {
            let filtered = presets.filter { $0.name != name }
            
            guard filtered.count != presets.count else {
                throw RemoveError.presetNotFound(name)
            }
            
            return filtered
        }
    }
}
