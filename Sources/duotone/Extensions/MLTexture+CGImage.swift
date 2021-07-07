//
//  MLTexture+CGImage.swift
//  duotone
//
//  Created by Carlo Eugster on 07.07.21.
//

import AppKit
import Metal
import MetalKit

extension MTLTexture {
    func bytes() throws -> UnsafeMutableRawPointer {
        let width = self.width
        let height = self.height
        let rowBytes = self.width * 4
        guard let pointer = malloc(width * height * 4) else {
            throw "Failed to allocate memory."
        }
        self.getBytes(pointer, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        return pointer
    }

    func toImage() throws -> CGImage {
        let pointer = try bytes()

        let pColorSpace = CGColorSpaceCreateDeviceRGB()
        let rawBitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)

        let selftureSize = self.width * self.height * 4
        let rowBytes = self.width * 4
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (_, _, _) -> Void in }
        guard let provider = CGDataProvider(dataInfo: nil, data: pointer, size: selftureSize, releaseData: releaseMaskImagePixelData),
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
            throw "Failed to create image."
        }

        return cgImageRef
    }
}
