//
//  MTLTexture+ThreadGroupsTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 16.06.20.
//

import XCTest
import Metal
import MetalKit
@testable import duotone

final class MTLTextureThreadGroupsTests: XCTestCase, @unchecked Sendable {
    
    // MARK: - Properties
    
    private var device: MTLDevice!
    private let threadGroupSize = 8 // Document the expected size
    
    // MARK: - Setup/Teardown
    
    override func setUp() {
        super.setUp()
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            XCTFail("Failed to create Metal device")
            return
        }
        device = metalDevice
    }
    
    override func tearDown() {
        device = nil
        super.tearDown()
    }
    
    // MARK: - Thread Group Count Tests
    
    /// Tests that thread group count is always 8x8x1 regardless of texture size
    func testThreadGroupCount() {
        let textures = [
            createTexture(width: 64, height: 64),
            createTexture(width: 100, height: 50),
            createTexture(width: 4, height: 6)
        ]
        
        textures.forEach { texture in
            let groupCount = texture.threadGroupCount()
            XCTAssertEqual(groupCount.width, threadGroupSize)
            XCTAssertEqual(groupCount.height, threadGroupSize)
            XCTAssertEqual(groupCount.depth, 1)
        }
    }
    
    // MARK: - Thread Groups Size Tests
    
    /// Tests texture dimensions that are exact multiples of thread group size
    func testThreadGroupsExactMultiple() {
        let texture = createTexture(width: 64, height: 64)
        let groups = texture.threadGroups()
        
        XCTAssertEqual(groups.width, 64/threadGroupSize)
        XCTAssertEqual(groups.height, 64/threadGroupSize)
        XCTAssertEqual(groups.depth, 1)
    }
    
    /// Tests texture dimensions that require ceiling division
    func testThreadGroupsWithRemainder() {
        let texture = createTexture(width: 100, height: 50)
        let groups = texture.threadGroups()
        
        XCTAssertEqual(groups.width, (100 + threadGroupSize - 1) / threadGroupSize)
        XCTAssertEqual(groups.height, (50 + threadGroupSize - 1) / threadGroupSize)
        XCTAssertEqual(groups.depth, 1)
    }
    
    /// Tests dimensions smaller than thread group size
    func testThreadGroupsSmallDimensions() {
        let texture = createTexture(width: 4, height: 6)
        let groups = texture.threadGroups()
        
        XCTAssertEqual(groups.width, 1)
        XCTAssertEqual(groups.height, 1)
        XCTAssertEqual(groups.depth, 1)
    }
    
    /// Tests large texture dimensions
    func testThreadGroupsLargeDimensions() {
        let texture = createTexture(width: 1024, height: 2048)
        let groups = texture.threadGroups()
        
        XCTAssertEqual(groups.width, 1024/threadGroupSize)
        XCTAssertEqual(groups.height, 2048/threadGroupSize)
        XCTAssertEqual(groups.depth, 1)
    }
    
    /// Tests edge case dimensions
    func testThreadGroupsEdgeCases() {
        // Test dimensions equal to thread group size
        let exactTexture = createTexture(width: threadGroupSize, height: threadGroupSize)
        let exactGroups = exactTexture.threadGroups()
        XCTAssertEqual(exactGroups.width, 1)
        XCTAssertEqual(exactGroups.height, 1)
        
        // Test dimensions one less than thread group size
        let almostTexture = createTexture(width: threadGroupSize - 1, height: threadGroupSize - 1)
        let almostGroups = almostTexture.threadGroups()
        XCTAssertEqual(almostGroups.width, 1)
        XCTAssertEqual(almostGroups.height, 1)
        
        // Test dimensions one more than thread group size
        let overTexture = createTexture(width: threadGroupSize + 1, height: threadGroupSize + 1)
        let overGroups = overTexture.threadGroups()
        XCTAssertEqual(overGroups.width, 2)
        XCTAssertEqual(overGroups.height, 2)
    }
    
    // MARK: - Helper Methods
    
    /// Creates a texture with the specified dimensions
    /// - Parameters:
    ///   - width: The width of the texture
    ///   - height: The height of the texture
    /// - Returns: The created texture
    private func createTexture(width: Int, height: Int) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: max(1, width), // Ensure valid dimensions
            height: max(1, height),
            mipmapped: false
        )
        
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            XCTFail("Failed to create texture with dimensions \(width)x\(height)")
            // Return a minimal valid texture as fallback
            return device.makeTexture(descriptor: MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: 1,
                height: 1,
                mipmapped: false
            ))!
        }
        
        return texture
    }
} 