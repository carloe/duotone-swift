//
//  NSImage+FileFormat.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

/// Errors that can occur during image format conversion
enum ImageFormatError: Error {
    case conversionFailed
    case invalidFormat
    case emptyImage
}

extension NSImage {
    /// Converts the image to data in the specified format
    /// - Parameter format: The desired output format
    /// - Returns: The image data in the specified format
    /// - Throws: ImageFormatError if conversion fails
    func representation(using format: FileFormat) throws -> Data {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ImageFormatError.conversionFailed
        }
        
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        
        var properties: [NSBitmapImageRep.PropertyKey: Any] = [:]
        if format == .jpg {
            properties[.compressionFactor] = 0.9
        }
        
        guard let data = imageRep.representation(using: format.nsBitmapFormat, properties: properties) else {
            throw ImageFormatError.conversionFailed
        }
        
        return data
    }
}

private extension FileFormat {
    /// Convert FileFormat to NSBitmapImageRep.FileType
    var nsBitmapFormat: NSBitmapImageRep.FileType {
        switch self {
        case .png:  return .png
        case .jpg: return .jpeg
        case .tiff: return .tiff
        case .bmp:  return .bmp
        }
    }
} 