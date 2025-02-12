//
//  MetalShaders.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import Foundation

/// Contains Metal shader source code
enum MetalShaders {
    /// Name of the main kernel function
    static let kernelName = "shaderKernel"
    
    /// Source code for the duotone shader
    static let duotoneShader = """
    #include <metal_stdlib>
    using namespace metal;

    // Constants for luminance calculation (Rec. 601 standard)
    constant float3 kLuminanceWeights = float3(0.299, 0.587, 0.114);

    /// Applies contrast adjustment to a color value
    float3 adjustContrast(float3 color, float contrast) {
        // Skip calculation if contrast is neutral
        if (contrast == 0.5) {
            return color;
        }
        
        // Normalize contrast to [-1, 1] range for more intuitive control
        float normalizedContrast = (contrast * 2.0) - 1.0;
        float3 midpoint = float3(0.5);
        
        return (color - midpoint) * (normalizedContrast + 1.0) + midpoint;
    }

    /// Calculates luminance of RGB color
    float calculateLuminance(float3 color) {
        return dot(color, kLuminanceWeights);
    }

    /// Applies duotone effect with blending
    float3 applyDuotone(float3 originalColor, float3 lightColor, float3 darkColor, float luminance, float blend) {
        // Calculate duotone color
        float3 duotoneColor = mix(darkColor, lightColor, luminance);
        
        // Blend between original and duotone color
        return mix(originalColor, duotoneColor, blend);
    }

    /// Main kernel function for duotone effect
    kernel void shaderKernel(
        texture2d<float, access::read> inTexture [[ texture(0) ]],
        texture2d<float, access::write> outTexture [[ texture(1) ]],
        constant float3 &lightColor [[ buffer(2) ]],
        constant float3 &darkColor [[ buffer(3) ]],
        constant float &duotoneContrast [[ buffer(4) ]],
        constant float &duotoneBlend [[ buffer(5) ]],
        uint2 gid [[ thread_position_in_grid ]]
    ) {
        // Read input color
        float4 inputColor = inTexture.read(gid);
        float3 rgb = inputColor.rgb;
        
        // Apply contrast adjustment
        rgb = adjustContrast(rgb, duotoneContrast);
        
        // Calculate luminance
        float lum = calculateLuminance(rgb);
        
        // Apply duotone effect with blending
        float3 processedColor = applyDuotone(rgb, lightColor, darkColor, lum, duotoneBlend);
        
        // Write output preserving original alpha
        outTexture.write(float4(processedColor, inputColor.a), gid);
    }
    """
} 