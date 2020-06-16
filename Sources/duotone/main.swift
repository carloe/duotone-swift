import ArgumentParser
import Foundation
import AppKit

struct DuotoneError: Error, CustomStringConvertible {
   var description: String
   
   init(_ description: String) { self.description = description }
}

struct Duotone: ParsableCommand {
   @Option(name: .shortAndLong, help: "Path to the input file")
   var input: String
   
   @Option(name: .shortAndLong, help: "The lightest color")
   var lightColor: String
   
   @Option(name: .shortAndLong, help: "The darkest color")
   var darkColor: String
   
   @Option(name: .shortAndLong, help: "Contrast value between 0.0 and 1.0")
   var contrast: Float?
   
   @Option(name: .shortAndLong, help: "Blend value between 0.0 and 1.0")
   var blend: Float?
   
   @Option(name: .shortAndLong, help: "Path to the output file")
   var output: String
   
   func run() throws {
      let startTime = CFAbsoluteTimeGetCurrent()
      
      guard let inColorLight = try? NSColor(hex: lightColor) else {
         throw ValidationError("Please provide a valid light hex color.")
      }
      
      guard let inColorDark = try? NSColor(hex: darkColor) else {
         throw ValidationError("Please provide a valid dark hex color.")
      }
      
      var contrastValue = (contrast != nil) ? CGFloat(contrast!) : 0.5
      if contrastValue > 1.0 { contrastValue = 1.0 }
      else if contrastValue < 0.0 { contrastValue = 0.0 }
      
      var blendValue = (blend != nil) ? CGFloat(blend!) : 1.0
      if blendValue > 1.0 { blendValue = 1.0 }
      else if blendValue < 0.0 { blendValue = 0.0 }
      
      let inputImage = try loadInputImage()
      let outputPath = try normalizedOutputPath()
      
      let outputImage: NSImage
      let format = FileFormat(filename: outputPath)
      do {
         outputImage = try ImageProcessor.colorMap(inputImage, darkColor: inColorDark, lightColor: inColorLight,
                                                   contrast: contrastValue, blend: blendValue)
      } catch {
         throw DuotoneError("Failed to initialize Metal shader.")
      }
      guard let outputData = outputImage.imageRepresentation(for: format) else {
         throw DuotoneError("Failed to save image,")
      }
      outputData.write(toFile: outputPath, atomically: false)
      
      let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
      print("Output: \(outputPath)")
      print("Completed in \(timeElapsed)s")
   }
   
   private func loadInputImage() throws -> NSImage {
      var isDirectory: ObjCBool = false
      let inputPath = input.standardizingPath
      if FileManager.default.fileExists(atPath: inputPath, isDirectory: &isDirectory) == false {
         throw DuotoneError("Input file does not exist at \(inputPath)")
      }
      guard let inputImage = NSImage(contentsOfFile: inputPath) else {
         throw DuotoneError("Could not read image at \(inputPath)")
      }
      return inputImage
   }
   
   private func normalizedOutputPath() throws -> String {
      var isDirectory: ObjCBool = false
      let outputPath = output.standardizingPath
      let url = URL(fileURLWithPath: outputPath)
      let directory = url.deletingLastPathComponent()
      if FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory) == false || isDirectory.boolValue == false {
         throw DuotoneError("Output path does not exist \(outputPath)")
      }
      return outputPath
   }
}

Duotone.main()
