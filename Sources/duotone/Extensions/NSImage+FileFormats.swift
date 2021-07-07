//
//  NSImage+FileFormats.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

enum FileFormat: String {
    case png
    case jpg
    case tiff
    case bmp

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpg:
            return "jpg"
        case .tiff:
            return "tiff"
        case .bmp:
            return "bmp"
        }
    }

    init(filename: String) {
        let ext = URL(fileURLWithPath: filename).pathExtension
        if ext == "png" {
            self = .png
        } else if ext == "tif" || ext == "tiff" {
            self = .tiff
        } else if ext == "bmp" {
            self = .bmp
        } else {
            self = .jpg
        }
    }
}

private extension FileFormat {
    var representationFormat: NSBitmapImageRep.FileType {
        switch self {
        case .png:
            return NSBitmapImageRep.FileType.png
        case .jpg:
            return NSBitmapImageRep.FileType.jpeg
        case .tiff:
            return NSBitmapImageRep.FileType.tiff
        case .bmp:
            return NSBitmapImageRep.FileType.bmp
        }
    }
}

extension NSImage {
    func imageRepresentation(for format: FileFormat) -> NSData? {
        if let data = self.tiffRepresentation, let imageRep = NSBitmapImageRep(data: data) {
            let properties: [NSBitmapImageRep.PropertyKey: Any] = [:]
            let imageData = imageRep.representation(using: format.representationFormat, properties: properties) as NSData?
            return imageData
        }
        return nil
    }
}
