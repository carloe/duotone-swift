//
//  MTLTexture+ThreadGroups.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import MetalKit

extension MTLTexture {
    func threadGroupCount() -> MTLSize {
        return MTLSizeMake(8, 8, 1)
    }

    func threadGroups() -> MTLSize {
        let groupCount = threadGroupCount()
        return MTLSize(width: (Int(width) + groupCount.width-1)/groupCount.width,
                       height: (Int(height) + groupCount.height-1)/groupCount.height,
                       depth: 1)
    }
}
