//
//  MLTexture+CGImage.swift
//  duotone
//
//  Created by Carlo Eugster on 07.07.21.
//

import AppKit
import Metal
import MetalKit

enum TextureError: Error, CustomStringConvertible {
    case memoryAllocationFailed
    case imageCreationFailed
    
    var description: String {
        switch self {
        case .memoryAllocationFailed:
            return "Failed to allocate memory."
        case .imageCreationFailed:
            return "Failed to create image."
        }
    }
}

extension MTLTexture {
    private func validateDimensions() throws {
        guard width > 0 && height > 0 else {
            throw TextureError.memoryAllocationFailed
        }
    }
    
    func bytes() throws -> UnsafeMutableRawPointer {
        try validateDimensions()
        
        // Check for valid pixel format
        guard self.pixelFormat == .rgba8Unorm else {
            throw TextureError.imageCreationFailed
        }
        
        let rowBytes = width * 4
        guard let pointer = malloc(width * height * 4) else {
            throw TextureError.memoryAllocationFailed
        }
        
        self.getBytes(pointer, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        return pointer
    }

    func toImage() throws -> CGImage {
        // Validate pixel format first
        guard self.pixelFormat == .rgba8Unorm else {
            throw TextureError.imageCreationFailed
        }
        
        let pointer = try bytes()

        let pColorSpace = CGColorSpaceCreateDeviceRGB()
        let rawBitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)

        let textureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (_, _, _) -> Void in }
        guard let provider = CGDataProvider(dataInfo: nil, data: pointer, size: textureSize, releaseData: releaseMaskImagePixelData),
              let cgImageRef = CGImage(width: self.width,
                                     height: self.height,
                                     bitsPerComponent: 8,
                                     bitsPerPixel: 32,
                                     bytesPerRow: rowBytes,
                                     space: pColorSpace,
                                     bitmapInfo: bitmapInfo,
                                     provider: provider,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: CGColorRenderingIntent.defaultIntent)
        else {
            throw TextureError.imageCreationFailed
        }

        return cgImageRef
    }

    func toCGImage() throws -> CGImage {
        // Validate pixel format first
        guard self.pixelFormat == .rgba8Unorm else {
            throw TextureError.imageCreationFailed
        }
        
        let width = self.width
        let height = self.height
        let rowBytes = width * 4
        guard let pointer = malloc(width * height * 4) else {
            throw TextureError.memoryAllocationFailed
        }
        
        self.getBytes(pointer, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: pointer,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: rowBytes,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo.rawValue),
              let image = context.makeImage() else {
            free(pointer)
            throw TextureError.imageCreationFailed
        }
        free(pointer)
        return image
    }
}
