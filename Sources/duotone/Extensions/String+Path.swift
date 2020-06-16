//
//  String+Path.swift
//  duotone
//
//  Created by Carlo Eugster on 16.06.20.
//

import Foundation

public extension String {
    var standardizingPath: String {
        var path = self
        if path.prefix(1) != "/" && path.prefix(1) != "~" {
            path = "\(FileManager.default.currentDirectoryPath)/\(path)"
        }
        return NSString(string: path).standardizingPath
    }
}
