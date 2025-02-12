//
//  NSImage+FileFormat.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

extension NSImage {
    /// Creates a data representation of the image in the specified format
    /// - Parameter format: The desired output format
    /// - Returns: Image data in the specified format, or nil if conversion fails
    func imageRepresentation(for format: FileFormat) -> Data? {
        guard let tiffData = tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        return imageRep.representation(
            using: format.representationFormat,
            properties: [:]
        ) as Data?
    }
} 