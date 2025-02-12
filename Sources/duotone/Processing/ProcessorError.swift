//
//  ProcessorError.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import Foundation

/// Errors that can occur during image processing
enum ProcessorError: LocalizedError {
    case deviceCreationFailed
    case queueCreationFailed
    case shaderCompilationFailed
    case textureCreationFailed
    case commandBufferCreationFailed
    case encoderCreationFailed
    case imageConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .deviceCreationFailed:
            return "Failed to create Metal device"
        case .queueCreationFailed:
            return "Failed to create Metal command queue"
        case .shaderCompilationFailed:
            return "Failed to compile Metal shader"
        case .textureCreationFailed:
            return "Failed to create Metal texture"
        case .commandBufferCreationFailed:
            return "Failed to create Metal command buffer"
        case .encoderCreationFailed:
            return "Failed to create Metal encoder"
        case .imageConversionFailed:
            return "Failed to convert image"
        }
    }
} 