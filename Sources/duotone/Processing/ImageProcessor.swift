//
//  ImageProcessor.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import AppKit
import Metal
import MetalKit

/// Processes images using Metal for GPU-accelerated duotone effects
final class ImageProcessor {
    // MARK: - Properties
    
    private let device: MTLDevice
    private let queue: MTLCommandQueue
    private let loader: MTKTextureLoader
    private let computePipelineState: MTLComputePipelineState
    
    // MARK: - Initialization
    
    /// Creates a new image processor
    /// - Throws: ProcessorError if Metal setup fails
    init() throws {
        // Initialize Metal device
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw ProcessorError.deviceCreationFailed
        }
        self.device = device
        
        // Create command queue
        guard let queue = device.makeCommandQueue() else {
            throw ProcessorError.queueCreationFailed
        }
        self.queue = queue
        
        // Set up Metal compute pipeline
        do {
            let library = try device.makeLibrary(
                source: MetalShaders.duotoneShader,
                options: nil
            )
            
            guard let function = library.makeFunction(name: MetalShaders.kernelName) else {
                throw ProcessorError.shaderCompilationFailed
            }
            
            self.computePipelineState = try device.makeComputePipelineState(function: function)
            self.loader = MTKTextureLoader(device: device)
        } catch {
            throw ProcessorError.shaderCompilationFailed
        }
    }
    
    // MARK: - Public Methods
    
    /// Applies a duotone effect to an image
    /// - Parameters:
    ///   - image: The input image to process
    ///   - darkColor: The dark color for the duotone effect
    ///   - lightColor: The light color for the duotone effect
    ///   - contrast: Contrast adjustment (0.0-1.0, default: 0.5)
    ///   - blend: Blend amount for the effect (0.0-1.0, default: 0.5)
    /// - Returns: The processed image
    /// - Throws: ProcessorError if processing fails
    func colorMap(
        _ image: NSImage,
        darkColor: NSColor,
        lightColor: NSColor,
        contrast: CGFloat = 0.5,
        blend: CGFloat = 0.5
    ) throws -> NSImage {
        // Create input texture
        guard let imageData = image.tiffRepresentation else {
            throw ProcessorError.imageConversionFailed
        }
        
        let inTexture = try loader.newTexture(data: imageData, options: nil)
        let outTexture = try createOutputTexture(matching: inTexture)
        
        // Process the image
        try processTexture(
            input: inTexture,
            output: outTexture,
            darkColor: darkColor,
            lightColor: lightColor,
            contrast: contrast,
            blend: blend
        )
        
        // Convert back to NSImage
        let cgImage = try outTexture.toImage()
        return NSImage(
            cgImage: cgImage,
            size: CGSize(width: cgImage.width, height: cgImage.height)
        )
    }
    
    // MARK: - Private Methods
    
    private func createOutputTexture(matching inputTexture: MTLTexture) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: inputTexture.width,
            height: inputTexture.height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead, .shaderWrite]
        
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            throw ProcessorError.textureCreationFailed
        }
        
        return texture
    }
    
    private func processTexture(
        input: MTLTexture,
        output: MTLTexture,
        darkColor: NSColor,
        lightColor: NSColor,
        contrast: CGFloat,
        blend: CGFloat
    ) throws {
        guard let buffer = queue.makeCommandBuffer() else {
            throw ProcessorError.commandBufferCreationFailed
        }
        
        try encodeComputeCommands(
            to: buffer,
            input: input,
            output: output,
            darkColor: darkColor,
            lightColor: lightColor,
            contrast: contrast,
            blend: blend
        )
        
        buffer.commit()
        buffer.waitUntilCompleted()
        
        if let error = buffer.error {
            throw error
        }
    }
    
    private func encodeComputeCommands(
        to buffer: MTLCommandBuffer,
        input: MTLTexture,
        output: MTLTexture,
        darkColor: NSColor,
        lightColor: NSColor,
        contrast: CGFloat,
        blend: CGFloat
    ) throws {
        guard let encoder = buffer.makeComputeCommandEncoder() else {
            throw ProcessorError.encoderCreationFailed
        }
        
        encoder.setComputePipelineState(computePipelineState)
        encoder.setTexture(input, index: 0)
        encoder.setTexture(output, index: 1)
        
        var lightColorFloat = simd_float3(
            Float(lightColor.redValue),
            Float(lightColor.greenValue),
            Float(lightColor.blueValue)
        )
        var darkColorFloat = simd_float3(
            Float(darkColor.redValue),
            Float(darkColor.greenValue),
            Float(darkColor.blueValue)
        )
        var contrastFloat = Float(contrast)
        var blendFloat = Float(blend)
        
        encoder.setBytes(&lightColorFloat, length: MemoryLayout.size(ofValue: lightColorFloat), index: 2)
        encoder.setBytes(&darkColorFloat, length: MemoryLayout.size(ofValue: darkColorFloat), index: 3)
        encoder.setBytes(&contrastFloat, length: MemoryLayout.size(ofValue: contrastFloat), index: 4)
        encoder.setBytes(&blendFloat, length: MemoryLayout.size(ofValue: blendFloat), index: 5)
        
        encoder.dispatchThreadgroups(
            input.threadGroups(),
            threadsPerThreadgroup: input.threadGroupCount()
        )
        encoder.endEncoding()
        
        guard let blitEncoder = buffer.makeBlitCommandEncoder() else {
            throw ProcessorError.encoderCreationFailed
        }
        blitEncoder.synchronize(resource: output)
        blitEncoder.endEncoding()
    }
} 