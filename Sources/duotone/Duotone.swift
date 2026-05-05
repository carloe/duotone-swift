import AppKit
import ArgumentParser
import Files
import Foundation

struct DuotoneError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) { self.description = description }
}

@main
struct Duotone: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for duotoning images.",
        version: "1.1.0",
        subcommands: [Process.self, Add.self, Remove.self, List.self],
        defaultSubcommand: Process.self)
}

extension Duotone {
    struct Process: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Duotone images.")

        @Argument(help: "The source file or folder")
        var inputPath: String

        @Option(name: [.short, .customLong("preset")], help: "The name of a preset")
        var presetName: String?

        @Option(name: [.short, .customLong("light")], help: "The lightest color in hex")
        var lightHexOption: String?

        @Option(name: [.short, .customLong("dark")], help: "The darkest color in hex")
        var darkHexOption: String?

        @Option(name: [.short, .customLong("contrast")], help: "Contrast value between 0.0 and 1.0")
        var contrastOption: Float?

        @Option(name: [.short, .customLong("blend")], help: "Blend value between 0.0 and 1.0")
        var blendOption: Float?

        @Flag(name: .shortAndLong, help: "Print verbose output")
        var verbose = false

        @Option(name: [.short, .customLong("out")], help: "Path where the output files are saved")
        var outputPath: String

        mutating func run() throws {
            let startTime = CFAbsoluteTimeGetCurrent()

            let preset = try preset()

            if verbose {
                print("🔎 Scanning '\(inputPath)'...")
            }
            let imagePaths = try processInput()
            if imagePaths.count == 0 {
                throw ValidationError("No images found at '\(inputPath)'")
            }
            if verbose, imagePaths.count > 1 {
                print("⚙️ Processing \(imagePaths.count) images...")
            }

            let outputFolder = try process(imagePaths, preset: preset)

            if verbose == true {
                let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                print("🚀 Done!\n")
                print("📂 Output: \(outputFolder.path)")
                print("⏱ Completed in \(String(format: "%.3f", timeElapsed))s")
            }
        }

        private func preset() throws -> Preset {
            let existing = presetName != nil ? try Duotone.loadPresets() : []
            return try resolvePreset(from: existing)
        }

        func resolvePreset(from existing: [Preset]) throws -> Preset {
            if let presetName = presetName {
                guard let preset = existing.first(where: { $0.name == presetName }) else {
                    throw ValidationError("No preset with name '\(presetName)' found.")
                }
                if verbose {
                    print("🏗 Running with preset '\(preset.name)'\n")
                }
                return preset
            }
            let contrast = CGFloat(contrastOption ?? 0.5).clamped(to: 0...1)
            let blend = CGFloat(blendOption ?? 1.0).clamped(to: 0...1)
            guard let lightHexOption = lightHexOption else {
                throw ValidationError("Please provide a light hex color.")
            }
            guard let darkHexOption = darkHexOption else {
                throw ValidationError("Please provide a dark hex color.")
            }
            return Preset(name: "cli", light: lightHexOption, dark: darkHexOption, contrast: contrast, blend: blend, description: nil)
        }

        private func process(_ imagePaths: [File], preset: Preset) throws -> Folder {
            let lightColor = try NSColor(hex: preset.light)
            let darkColor = try NSColor(hex: preset.dark)

            let outputFolder = try Folder(path: outputPath)
            let processor = try ImageProcessor()
            for (index, file) in imagePaths.enumerated() {
                if verbose {
                    print("- [\(index + 1)/\(imagePaths.count)] Processing: \(file.name)")
                }

                guard let ext = file.extension,
                      let format = FileFormat(rawValue: ext),
                      let inputImage = NSImage(contentsOfFile: file.path)
                else {
                    throw ValidationError("Failed to load \(file.name)")
                }

                let outputImage = try processor.colorMap(inputImage,
                                                         darkColor: darkColor,
                                                         lightColor: lightColor,
                                                         contrast: preset.contrast,
                                                         blend: preset.blend)
                guard let outputData = outputImage.imageRepresentation(for: format) as Data? else {
                    throw ValidationError("Failed to save '\(file.name)'")
                }

                try outputFolder.createFile(at: file.name, contents: outputData)
            }
            return outputFolder
        }

        func processInput() throws -> [File] {
            if let file = try? File(path: inputPath) {
                if let ext = file.extension, FileFormat.allValidExtensions.contains(ext) {
                    return [file]
                }
                throw ValidationError("\(file.name) is not a valid image format.")
            } else {
                var inputFiles = [File]()
                for file in try Folder(path: inputPath).files {
                    if let ext = file.extension, FileFormat.allValidExtensions.contains(ext) {
                        inputFiles.append(file)
                    }
                }
                return inputFiles
            }
        }
    }
}
