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
    /// Command to list all available presets
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List all presets.",
            discussion: "Displays a list of all available color presets with their properties."
        )

        // MARK: - Properties
        
        @Flag(
            name: [.customShort("c"), .long],
            help: "Show only preset names in a compact format"
        )
        var compact = false
        
        // MARK: - Methods

        mutating func run() throws {
            let presets = try Duotone.loadPresets()
            
            if presets.isEmpty {
                print("No presets found.")
                return
            }
            
            if compact {
                printCompactList(presets)
            } else {
                printDetailedList(presets)
            }
        }
        
        private func printCompactList(_ presets: [Preset]) {
            presets.forEach { print($0.name) }
        }
        
        private func printDetailedList(_ presets: [Preset]) {
            print("Available presets (\(presets.count)):\n")
            
            presets.forEach { preset in
                print("""
                    \(preset.name):
                      Light: \(preset.light)
                      Dark: \(preset.dark)
                      Contrast: \(String(format: "%.2f", preset.contrast))
                      Blend: \(String(format: "%.2f", preset.blend))
                    """)
                
                if let description = preset.description {
                    print("      Description: \(description)")
                }
                print("")
            }
        }
    }
}
