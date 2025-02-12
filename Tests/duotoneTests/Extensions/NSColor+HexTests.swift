//
//  NSColor+HexTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 16.06.20.
//

import XCTest
import AppKit
@testable import duotone

final class NSColorHexTests: XCTestCase {
    
    // MARK: - Valid Hex Strings
    
    func testValidHexWithHash() throws {
        let color = try NSColor(hex: "#FF0000")
        XCTAssertEqual(color.redValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 0.0, accuracy: 0.001)
    }
    
    func testValidHexWithoutHash() throws {
        let color = try NSColor(hex: "00FF00")
        XCTAssertEqual(color.redValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 0.0, accuracy: 0.001)
    }
    
    func testValidLowercaseHex() throws {
        let color = try NSColor(hex: "#ff00ff")
        XCTAssertEqual(color.redValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 1.0, accuracy: 0.001)
    }
    
    func testValidMixedCaseHex() throws {
        let color = try NSColor(hex: "#Ff00Ff")
        XCTAssertEqual(color.redValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 1.0, accuracy: 0.001)
    }
    
    private let colorAccuracy: CGFloat = 0.01  // 1% accuracy is sufficient for colors
    
    func testValidPartialValues() throws {
        let color = try NSColor(hex: "#808080")
        XCTAssertEqual(color.redValue, 0.5, accuracy: colorAccuracy)
        XCTAssertEqual(color.greenValue, 0.5, accuracy: colorAccuracy)
        XCTAssertEqual(color.blueValue, 0.5, accuracy: colorAccuracy)
    }
    
    // MARK: - Invalid Hex Strings
    
    func testInvalidLength() {
        XCTAssertThrowsError(try NSColor(hex: "#12345")) { error in
            XCTAssertEqual(error as? ColorError, .invalidHexString)
        }
    }
    
    func testInvalidCharacters() {
        XCTAssertThrowsError(try NSColor(hex: "#12G456")) { error in
            XCTAssertEqual(error as? ColorError, .invalidHexString)
        }
    }
    
    func testEmptyString() {
        XCTAssertThrowsError(try NSColor(hex: "")) { error in
            XCTAssertEqual(error as? ColorError, .invalidHexString)
        }
    }
    
    func testInvalidFormat() {
        XCTAssertThrowsError(try NSColor(hex: "12-34-56")) { error in
            XCTAssertEqual(error as? ColorError, .invalidHexString)
        }
    }
    
    // MARK: - Edge Cases
    
    func testBlackColor() throws {
        let color = try NSColor(hex: "#000000")
        XCTAssertEqual(color.redValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 0.0, accuracy: 0.001)
    }
    
    func testWhiteColor() throws {
        let color = try NSColor(hex: "#FFFFFF")
        XCTAssertEqual(color.redValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 1.0, accuracy: 0.001)
    }
    
    // MARK: - String Conversion
    
    func testHexStringConversion() throws {
        let originalHex = "#FF00FF"
        let color = try NSColor(hex: originalHex)
        let hexString = color.hexString
        
        XCTAssertEqual(hexString.uppercased(), originalHex)
    }
    
    func testHexStringRoundTrip() throws {
        let testCases = [
            "#FF0000",
            "#00FF00",
            "#0000FF",
            "#FFFFFF",
            "#000000",
            "#808080"
        ]
        
        for hex in testCases {
            let color = try NSColor(hex: hex)
            let roundTrip = color.hexString
            XCTAssertEqual(roundTrip.uppercased(), hex)
        }
    }
    
    // MARK: - Alpha Support
    
    func testRGBAColorWithAlpha() throws {
        let color = try NSColor(hex: "#FF0000FF")
        XCTAssertEqual(color.redValue, 1.0, accuracy: 0.001)
        XCTAssertEqual(color.greenValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.blueValue, 0.0, accuracy: 0.001)
        XCTAssertEqual(color.alphaValue, 1.0, accuracy: 0.001)
    }
    
    func testRGBAColorWithPartialAlpha() throws {
        let color = try NSColor(hex: "#FF000080")
        XCTAssertEqual(color.redValue, 1.0, accuracy: colorAccuracy)
        XCTAssertEqual(color.greenValue, 0.0, accuracy: colorAccuracy)
        XCTAssertEqual(color.blueValue, 0.0, accuracy: colorAccuracy)
        XCTAssertEqual(color.alphaValue, 0.5, accuracy: colorAccuracy)
    }
    
    func testRGBColorDefaultAlpha() throws {
        let color = try NSColor(hex: "#FF0000")
        XCTAssertEqual(color.alphaValue, 1.0, accuracy: 0.001)
    }
    
    func testHexStringWithAlpha() throws {
        let color = try NSColor(hex: "#FF000080")
        XCTAssertEqual(color.hexString.uppercased(), "#FF000080")
    }
    
    func testHexStringWithoutAlpha() throws {
        let color = try NSColor(hex: "#FF0000")
        XCTAssertEqual(color.hexString.uppercased(), "#FF0000")
    }
} 