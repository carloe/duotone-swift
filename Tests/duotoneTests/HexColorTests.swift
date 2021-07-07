//
//  HexColorTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 07.07.21.
//

import XCTest

class HexColorTests: XCTestCase {

    // MARK: Hex Parsing

    func testParsingWithEmptyValueHex() throws {
        XCTAssertThrowsError( try NSColor(hex: ""))
    }

    func testParsingWithTwoValueHex() throws {
        let hexColor = "#33"

        let color = try NSColor(hex: hexColor)

        XCTAssertEqual(color.redValue * 255, 51)
        XCTAssertEqual(color.greenValue * 255, 51)
        XCTAssertEqual(color.blueValue * 255, 51)
        XCTAssertEqual(color.alphaValue, 1.0)
    }

    func testParsingWithThreeValueHex() throws {
        let hexColor = "#8A3"

        let color = try NSColor(hex: hexColor)

        XCTAssertEqual(color.redValue * 255, 136)
        XCTAssertEqual(color.greenValue * 255, 170)
        XCTAssertEqual(color.blueValue * 255, 51)
        XCTAssertEqual(color.alphaValue, 1.0)
    }

    func testParsingWithFourValueHex() throws {
        let hexColor = "#f363"

        let color = try NSColor(hex: hexColor)

        XCTAssertEqual(color.redValue * 255, 255)
        XCTAssertEqual(color.greenValue * 255, 51)
        XCTAssertEqual(color.blueValue * 255, 102)
        XCTAssertEqual(color.alphaValue, 0.2)
    }

    func testParsingWithFiveValueHex() throws {
        let hexColor = "#f363F"
        XCTAssertThrowsError( try NSColor(hex: hexColor))
    }

    func testParsingWithSixleValueHex() throws {
        let hexColor = "#335490"

        let color = try NSColor(hex: hexColor)

        XCTAssertEqual(color.redValue * 255, 51)
        XCTAssertEqual(color.greenValue * 255, 84)
        XCTAssertEqual(color.blueValue * 255, 144)
        XCTAssertEqual(color.alphaValue * 255, 255)
    }

    func testParsingWithEightleValueHex() throws {
        let hexColor = "#1A752154"

        let color = try NSColor(hex: hexColor)

        XCTAssertEqual(color.redValue * 255, 26)
        XCTAssertEqual(color.greenValue * 255, 117)
        XCTAssertEqual(color.blueValue * 255, 33)
        XCTAssertEqual(color.alphaValue * 255, 84)
    }

    func testParsingWithInvalidHex() throws {
        let hexColor = "hello"
        XCTAssertThrowsError( try NSColor(hex: hexColor))
    }

    func testParsingWithNakedValueHex() throws {
        let hexColor = "1A752154"

        let color = try NSColor(hex: hexColor)

        XCTAssertEqual(color.redValue * 255, 26)
        XCTAssertEqual(color.greenValue * 255, 117)
        XCTAssertEqual(color.blueValue * 255, 33)
        XCTAssertEqual(color.alphaValue * 255, 84)
    }

    // MARK: Hex String

    func testToHexStringWithNakedHex() throws {
        let hexColor = "1A752154"
        let color = try NSColor(hex: hexColor)
        XCTAssertEqual(color.toHexString(), "#1A7521")
    }

    func testToHexStringWidthSingleValue() throws {
        let hexColor = "#ff"
        let color = try NSColor(hex: hexColor)
        XCTAssertEqual(color.toHexString(), "#FFFFFF")
    }

    // MARK: Values

    func testColorValues() throws {
        let red: CGFloat = CGFloat.random(in: 0...1)
        let green: CGFloat = CGFloat.random(in: 0...1)
        let blue: CGFloat = CGFloat.random(in: 0...1)
        let alpha: CGFloat = CGFloat.random(in: 0...1)

        let color = NSColor(red: red, green: green, blue: blue, alpha: alpha)

        XCTAssertEqual(color.redValue, red)
        XCTAssertEqual(color.greenValue, green)
        XCTAssertEqual(color.blueValue, blue)
        XCTAssertEqual(color.alphaValue, alpha)
    }
}
