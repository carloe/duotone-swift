//
//  MTLTexture+ThreadGroups.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import MetalKit

extension MTLTexture {
    /// The fixed size of a thread group for optimal GPU performance
    private static var threadGroupSize: MTLSize {
        return MTLSizeMake(8, 8, 1)
    }
    
    /// Returns the optimal thread group count for this texture
    /// - Returns: A size of 8x8x1 for optimal GPU performance
    func threadGroupCount() -> MTLSize {
        return Self.threadGroupSize
    }
    
    /// Calculates the number of thread groups needed to process the entire texture
    /// - Returns: The number of thread groups in each dimension
    func threadGroups() -> MTLSize {
        let groupCount = threadGroupCount()
        
        // Use ceiling division to ensure all pixels are covered
        let widthGroups = (Int(width) + groupCount.width - 1) / groupCount.width
        let heightGroups = (Int(height) + groupCount.height - 1) / groupCount.height
        
        return MTLSize(
            width: widthGroups,
            height: heightGroups,
            depth: 1  // 2D textures always have depth of 1
        )
    }
}
