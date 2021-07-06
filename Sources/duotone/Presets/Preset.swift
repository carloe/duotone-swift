//
//  Preset.swift
//  ArgumentParser
//
//  Created by Carlo Eugster on 05.07.21.
//

import Foundation

struct Preset: Codable {
    var name: String
    var light: String
    var dark: String
    var contrast: CGFloat
    var blend: CGFloat
    var description: String?
}
