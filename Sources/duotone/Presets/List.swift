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
    /// Command to list all available presets in either compact or detailed format
    struct List: ParsableCommand {
        // MARK: - Constants
        
        private enum Constants {
            static let indentation = "  "
            static let floatFormat = "%.2f"
        }
        
        // MARK: - Configuration
        
        static let configuration = CommandConfiguration(
            abstract: "List all presets.",
            discussion: """
                Displays a list of all available color presets.
                Use --compact (-c) for a simple list of preset names, \
                or the default detailed view for complete preset information.
                """
        )

        // MARK: - Properties
        
        @Flag(
            name: [.customShort("c"), .long],
            help: ArgumentHelp(
                "Show only preset names in a compact format",
                discussion: "Useful for scripting or when only names are needed"
            )
        )
        var compact = false
        
        // MARK: - Command Execution
        
        mutating func run() throws {
            let presets = try PresetStorage.loadPresets()
            
            guard !presets.isEmpty else {
                print("No presets found.")
                return
            }
            
            displayPresets(presets)
        }
        
        // MARK: - Private Methods
        
        private func displayPresets(_ presets: [Preset]) {
            if compact {
                printCompactList(presets)
            } else {
                printDetailedList(presets)
            }
        }
        
        private func printCompactList(_ presets: [Preset]) {
            presets
                .map(\.name)
                .forEach { print($0) }
        }
        
        private func printDetailedList(_ presets: [Preset]) {
            print("Available presets (\(presets.count)):\n")
            
            presets.forEach { preset in
                printPresetDetails(preset)
                print("")  // Add blank line between presets
            }
        }
        
        private func printPresetDetails(_ preset: Preset) {
            print("""
                \(preset.name):
                \(Constants.indentation)Light: \(preset.light)
                \(Constants.indentation)Dark: \(preset.dark)
                \(Constants.indentation)Contrast: \(String(format: Constants.floatFormat, preset.contrast))
                \(Constants.indentation)Blend: \(String(format: Constants.floatFormat, preset.blend))
                """)
            
            if let description = preset.presetDescription {
                print("\(Constants.indentation)Description: \(description)")
            }
        }
    }
}
