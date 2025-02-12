//
//  main.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit
import ArgumentParser
import Files
import Foundation

// MARK: - Error Types

/// Custom errors for the duotone command-line tool
enum DuotoneError: LocalizedError {
    case invalidInput(String)
    case processingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        }
    }
}

// MARK: - Main Command

/// Main command for the duotone command-line tool
struct Duotone: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for duotoning images.",
        version: "1.0.1",
        subcommands: [Process.self, Add.self, Remove.self, List.self],
        defaultSubcommand: Process.self
    )
}

// MARK: - Process Command

extension Duotone {
    /// Command to process images with duotone effects
    struct Process: ParsableCommand {
        // MARK: - Configuration
        
        static let configuration = CommandConfiguration(
            abstract: "Process images with duotone effects.",
            discussion: "Apply duotone effects to images using either a preset or custom colors."
        )
        
        // MARK: - Properties
        
        @Argument(
            help: ArgumentHelp(
                "The source file or folder to process",
                discussion: "Can be a single image file or a folder containing images"
            )
        )
        var inputPath: String
        
        @Option(
            name: [.short, .customLong("preset")],
            help: "The name of a preset to use"
        )
        var presetName: String?
        
        @Option(
            name: [.short, .customLong("light")],
            help: "The lightest color in hex format (e.g., #FFFFFF)"
        )
        var lightHexOption: String?
        
        @Option(
            name: [.short, .customLong("dark")],
            help: "The darkest color in hex format (e.g., #000000)"
        )
        var darkHexOption: String?
        
        @Option(
            name: [.short, .customLong("contrast")],
            help: "Contrast value between 0.0 and 1.0"
        )
        var contrastOption: Float?
        
        @Option(
            name: [.short, .customLong("blend")],
            help: "Blend value between 0.0 and 1.0"
        )
        var blendOption: Float?
        
        @Option(
            name: [.short, .customLong("out")],
            help: "Path where the output files will be saved"
        )
        var outputPath: String
        
        @Flag(
            name: .shortAndLong,
            help: "Print verbose output during processing"
        )
        var verbose = false
        
        // MARK: - Constants
        
        private enum Constants {
            static let defaultContrast: Float = 0.5
            static let defaultBlend: Float = 1.0
        }
        
        // MARK: - Command Execution
        
        mutating func run() throws {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Load and validate preset/colors
            let preset = try loadPreset()
            
            // Find and validate input files
            let imagePaths = try findImageFiles()
            guard !imagePaths.isEmpty else {
                throw DuotoneError.invalidInput("No valid images found at '\(inputPath)'")
            }
            
            logVerbose("🔎 Found \(imagePaths.count) image(s) to process")
            
            // Process images
            let outputFolder = try processImages(imagePaths, preset: preset)
            
            // Print completion message
            if verbose {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                printCompletionMessage(outputFolder: outputFolder, timeElapsed: timeElapsed)
            }
        }
        
        // MARK: - Private Methods
        
        private func loadPreset() throws -> Preset {
            if let presetName = presetName {
                return try loadNamedPreset(presetName)
            }
            return try createCustomPreset()
        }
        
        private func loadNamedPreset(_ name: String) throws -> Preset {
            let presets = try PresetStorage.loadPresets()
            guard let preset = presets.first(where: { $0.name == name }) else {
                throw DuotoneError.invalidInput("No preset with name '\(name)' found")
            }
            
            logVerbose("🏗 Using preset '\(preset.name)'")
            return preset
        }
        
        private func createCustomPreset() throws -> Preset {
            guard let lightHex = lightHexOption else {
                throw DuotoneError.invalidInput("Please provide a light hex color")
            }
            guard let darkHex = darkHexOption else {
                throw DuotoneError.invalidInput("Please provide a dark hex color")
            }
            
            let contrast = contrastOption.map { min(max($0, 0.0), 1.0) } ?? Constants.defaultContrast
            let blend = blendOption.map { min(max($0, 0.0), 1.0) } ?? Constants.defaultBlend
            
            return Preset(
                name: "cli",
                light: lightHex,
                dark: darkHex,
                contrast: CGFloat(contrast),
                blend: CGFloat(blend)
            )
        }
        
        private func findImageFiles() throws -> [File] {
            if let file = try? File(path: inputPath) {
                guard let ext = file.extension,
                      FileFormat.allValidExtensions.contains(ext) else {
                    throw DuotoneError.invalidInput("\(file.name) is not a valid image format")
                }
                return [file]
            }
            
            let folder = try Folder(path: inputPath)
            return folder.files.filter { file in
                guard let ext = file.extension else { return false }
                return FileFormat.allValidExtensions.contains(ext)
            }
        }
        
        private func processImages(_ files: [File], preset: Preset) throws -> Folder {
            let lightColor = try NSColor(hex: preset.light)
            let darkColor = try NSColor(hex: preset.dark)
            let outputFolder = try Folder(path: outputPath)
            let processor = try ImageProcessor()
            
            for (index, file) in files.enumerated() {
                logVerbose("- [\(index + 1)/\(files.count)] Processing: \(file.name)")
                try processImage(file, using: processor, lightColor: lightColor, darkColor: darkColor, preset: preset, outputFolder: outputFolder)
            }
            
            return outputFolder
        }
        
        private func processImage(_ file: File, using processor: ImageProcessor, lightColor: NSColor, darkColor: NSColor, preset: Preset, outputFolder: Folder) throws {
            guard let ext = file.extension,
                  let format = FileFormat(rawValue: ext),
                  let inputImage = NSImage(contentsOfFile: file.path) else {
                throw DuotoneError.processingFailed("Failed to load \(file.name)")
            }
            
            let outputImage = try processor.colorMap(
                inputImage,
                darkColor: darkColor,
                lightColor: lightColor,
                contrast: preset.contrast,
                blend: preset.blend
            )
            
            let outputData = try outputImage.representation(using: format)
            
            try outputFolder.createFile(at: file.name, contents: outputData)
        }
        
        private func logVerbose(_ message: String) {
            guard verbose else { return }
            print(message)
        }
        
        private func printCompletionMessage(outputFolder: Folder, timeElapsed: CFAbsoluteTime) {
            print("""
                🚀 Done!
                
                📂 Output: \(outputFolder.path)
                ⏱ Completed in \(String(format: "%.3f", timeElapsed))s
                """)
        }
    }
}

// Start the command-line tool
Duotone.main()
