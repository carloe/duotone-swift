//
//  ImageProcessor.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit
import Metal
import MetalKit

enum ProcessorError: Error {
    case unknown
    case failedToCreateMetalDevice
    case failedToCreateMetalQueue
    case failedToCreateMetalFunction
    case failedToCreateCPUKernel
    case failedToCreateTexture
    case failedToCreateMetalCommandBuffer
    case failedToCreateMetalEncoder
    case failedToCreateCGImage
}

class ImageProcessor {
    private static let functionName = "shaderKernel"
    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;

    kernel void shaderKernel(texture2d<float, access::read> inTexture [[ texture(0) ]],
                             texture2d<float, access::write> outTexture [[ texture(1) ]],
                             constant float3 &lightColor [[ buffer(2) ]],
                             constant float3 &darkColor [[ buffer(3) ]],
                             constant float &duotoneContrast [[ buffer(4) ]],
                             constant float &duotoneBlend [[ buffer(5) ]],
                             uint2 gid [[ thread_position_in_grid ]]) {
        float4 texColor = inTexture.read(gid);

        float red = texColor.r;
        float green = texColor.g;
        float blue = texColor.b;
        if (duotoneContrast != 0.5) {
            float normalizedContrast = (1.0 + duotoneContrast - 0.5);
            red = (red  - 0.5) * normalizedContrast + 0.5;
            green = (green  - 0.5) * normalizedContrast + 0.5;
            blue = (blue  - 0.5) * normalizedContrast + 0.5;
        }
        float lum = 0.299 * red + 0.587 * green + 0.114 * blue;
        float newRed = ((lightColor.r * lum + (darkColor.r * (1.0 - lum))) * duotoneBlend) + (red * (1.0 - duotoneBlend));
        float newGreen = ((lightColor.g * lum + (darkColor.g * (1.0 - lum))) * duotoneBlend) + (green * (1.0 - duotoneBlend));
        float newBlue = ((lightColor.b * lum + (darkColor.b * (1.0 - lum))) * duotoneBlend) + (blue * (1.0 - duotoneBlend));
        texColor = float4(newRed, newGreen, newBlue, texColor.a);

        outTexture.write(texColor, gid);
    }
    """

    private var device: MTLDevice!
    private var queue: MTLCommandQueue!
    private var loader: MTKTextureLoader!
    private var computePipelineState: MTLComputePipelineState!

    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw ProcessorError.failedToCreateMetalDevice
        }
        self.device = device

        guard let queue = device.makeCommandQueue() else {
            throw ProcessorError.failedToCreateMetalQueue
        }
        self.queue = queue

        let library = try self.device.makeLibrary(source: ImageProcessor.shaderSource, options: nil)
        guard let function = library.makeFunction(name: ImageProcessor.functionName) else {
            throw ProcessorError.failedToCreateMetalFunction
        }

        self.computePipelineState = try self.device.makeComputePipelineState(function: function)
        self.loader = MTKTextureLoader(device: device)
    }

    func colorMap(_ image: NSImage, darkColor: NSColor, lightColor: NSColor, contrast: CGFloat = 0.5, blend: CGFloat = 0.5) throws -> NSImage {
        guard let imageData = image.tiffRepresentation else {
            throw ProcessorError.unknown
        }

        let inTexture = try loader.newTexture(data: imageData, options: nil)
        let (width, height) = (inTexture.width, inTexture.height)
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        outTextureDescriptor.usage = [.shaderRead, .shaderWrite]
        guard let outTexture = device.makeTexture(descriptor: outTextureDescriptor) else { throw ProcessorError.failedToCreateTexture }

        guard let buffer = queue.makeCommandBuffer() else { throw ProcessorError.failedToCreateMetalCommandBuffer }
        guard let computeEncoder = buffer.makeComputeCommandEncoder() else { throw ProcessorError.failedToCreateMetalEncoder }

        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setTexture(inTexture, index: 0)
        computeEncoder.setTexture(outTexture, index: 1)

        var lightColor = ImageProcessor.float3From(color: lightColor)
        var darkColor = ImageProcessor.float3From(color: darkColor)
        var contrastFloat = Float(contrast)
        var blendFloat = Float(blend)

        computeEncoder.setBytes(&lightColor, length: MemoryLayout.size(ofValue: lightColor), index: 2)
        computeEncoder.setBytes(&darkColor, length: MemoryLayout.size(ofValue: darkColor), index: 3)
        computeEncoder.setBytes(&contrastFloat, length: MemoryLayout.size(ofValue: contrastFloat), index: 4)
        computeEncoder.setBytes(&blendFloat, length: MemoryLayout.size(ofValue: blendFloat), index: 5)

        computeEncoder.dispatchThreadgroups(inTexture.threadGroups(), threadsPerThreadgroup: inTexture.threadGroupCount())
        computeEncoder.endEncoding()

        guard let blitEncoder = buffer.makeBlitCommandEncoder() else { throw ProcessorError.failedToCreateMetalEncoder }
        blitEncoder.synchronize(resource: outTexture)
        blitEncoder.endEncoding()

        buffer.commit()
        buffer.waitUntilCompleted()

        if let error = buffer.error { throw error }
        return try ImageProcessor.cgImage(from: outTexture)
    }

    private static func cgImage(from texture: MTLTexture) throws -> NSImage {
        let (width, height) = (texture.width, texture.height)
        let rowBytes = width * 4

        var buffer = [UInt8](repeating: 0, count: rowBytes * height)
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(&buffer, bytesPerRow: rowBytes, from: region, mipmapLevel: 0)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: &buffer,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: rowBytes,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            throw ProcessorError.failedToCreateCGImage
        }
        guard let result = context.makeImage() else { throw ProcessorError.failedToCreateCGImage }
        return NSImage(cgImage: result, size: CGSize(width: result.width, height: result.height))
    }

    private static func float3From(color: NSColor) -> simd_float3 {
        return simd_float3(Float(color.redValue), Float(color.greenValue), Float(color.blueValue))
    }
}
