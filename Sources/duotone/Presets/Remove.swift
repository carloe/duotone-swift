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
    struct Remove: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Remove a presets.")

        @Option(name: .long, help: "The name of the preset")
        var name: String

        mutating func run() throws {
            let presets = try Duotone.loadPresets()
            let filtered = presets.filter { $0.name != name}
            if presets.count == filtered.count {
                throw "No existing preset with name '\(name)' found"
            }
            try Duotone.savePresets(filtered)
            print("Removed '\(name)'")
        }
    }
}
