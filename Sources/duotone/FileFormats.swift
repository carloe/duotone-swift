//
//  FileFormat.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit

/// Represents supported image file formats for processing
enum FileFormat: String, CaseIterable {
    // MARK: - Cases
    
    case png
    case jpg
    case tiff
    case bmp
    
    // MARK: - Static Properties
    
    /// All valid file extensions supported by the application
    static var allValidExtensions: [String] {
        allCases.flatMap(\.validExtensions)
    }
    
    // MARK: - Properties
    
    /// Primary file extension for this format
    var fileExtension: String {
        validExtensions[0]
    }
    
    /// All valid file extensions for this format
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
    
    /// The corresponding NSBitmapImageRep.FileType for this format
    var representationFormat: NSBitmapImageRep.FileType {
        switch self {
        case .png:
            return .png
        case .jpg:
            return .jpeg
        case .tiff:
            return .tiff
        case .bmp:
            return .bmp
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a FileFormat from a file extension string
    /// - Parameter rawValue: The file extension to check
    init?(rawValue: String) {
        let lowercasedValue = rawValue.lowercased()
        guard let format = FileFormat.allCases.first(where: { 
            $0.validExtensions.contains(lowercasedValue) 
        }) else {
            return nil
        }
        self = format
    }
} 