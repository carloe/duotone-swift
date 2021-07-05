import AppKit
import ArgumentParser
import Files
import Foundation

struct DuotoneError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) { self.description = description }
}

private let validImageExtensions = ["jpg", "jpeg", "png"]

struct Duotone: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for duotoning images.",
        version: "1.0.0",
        subcommands: [Process.self, Add.self, Remove.self, List.self],
        defaultSubcommand: Process.self)
}

extension Duotone {
    struct Process: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Duotone images.")

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
            if let presetName = presetName {
                let presets = try Duotone.loadPresets()
                let preset = presets.first {  $0.name == presetName }
                guard let preset = preset else {
                    throw ValidationError("No preset with name '\(presetName)' found.")
                }
                if verbose {
                    print("🏗 Running with preset '\(preset.name)'\n")
                }
                return preset
            }
            var contrast = (contrastOption != nil) ? CGFloat(contrastOption!) : 0.5
            if contrast > 1.0 { contrast = 1.0 } else if contrast < 0.0 { contrast = 0.0 }

            var blend = (blendOption != nil) ? CGFloat(blendOption!) : 1.0
            if blend > 1.0 { blend = 1.0 } else if blend < 0.0 { blend = 0.0 }
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
                guard let inputImage = NSImage(contentsOfFile: file.path) else {
                    throw ValidationError("Could not read image at \(file.path)")
                }
                let format = FileFormat(filename: outputPath)
                let outputImage = try processor.colorMap(inputImage,
                                                         darkColor: darkColor,
                                                         lightColor: lightColor,
                                                         contrast: preset.contrast,
                                                         blend: preset.blend)
                guard let outputData = outputImage.imageRepresentation(for: format) as Data? else {
                    throw ValidationError("Failed to save image.")
                }

                try outputFolder.createFile(at: file.name, contents: outputData)
            }
            return outputFolder
        }

        private func processInput() throws -> [File] {
            if let file = try? File(path: inputPath) {
                if let ext = file.extension, validImageExtensions.contains(ext) {
                    return [file]
                }
                throw ValidationError("\(file.name) is not a valid image format.")
            } else {
                var inputFiles = [File]()
                for file in try Folder(path: inputPath).files {
                    if let ext = file.extension, validImageExtensions.contains(ext) {
                        inputFiles.append(file)
                    }
                }
                return inputFiles
            }
        }
    }
}

Duotone.main()
