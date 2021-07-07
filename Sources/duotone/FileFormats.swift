//
//  NSImage+FileFormats.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

enum FileFormat: String, CaseIterable {
    case png
    case jpg
    case tiff
    case bmp

    static private var _allValidExtensions: [String]?
    static var allValidExtensions: [String] {
        if let exts = _allValidExtensions { return exts }
        var exts = [String]()
        for format in self.allCases {
            exts.append(contentsOf: format.validExtensions)
        }
        _allValidExtensions = exts
        return exts
    }

    var fileExtension: String {
        return self.validExtensions.first!
    }

    var validExtensions: [String] {
        switch self {
        case .png:
            return ["png"]
        case .jpg:
            return ["jpg", "jpeg"]
        case .tiff:
            return ["tiff", "tif"]
        case .bmp:
            return ["bmp"]
        }
    }

    init?(rawValue: String) {
        for format in FileFormat.allCases {
            if format.validExtensions.contains(rawValue.lowercased()) {
                self = format
                return
            }
        }
        return nil
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
