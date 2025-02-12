//
//  NSImage+FileFormatTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 16.06.20.
//

import XCTest
import AppKit
@testable import duotone

final class NSImageFileFormatTests: XCTestCase {
    
    // MARK: - Properties
    
    private var testImage: NSImage!
    
    // MARK: - Setup/Teardown
    
    override func setUp() {
        super.setUp()
        testImage = createTestImage(size: NSSize(width: 100, height: 100))
    }
    
    override func tearDown() {
        testImage = nil
        super.tearDown()
    }
    
    // MARK: - Format Tests
    
    func testPNGRepresentation() throws {
        let data = try testImage.representation(using: .png)
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
        XCTAssertTrue(NSImage(data: data) != nil)
    }
    
    func testJPEGRepresentation() throws {
        let data = try testImage.representation(using: .jpg)
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
        XCTAssertTrue(NSImage(data: data) != nil)
    }
    
    func testTIFFRepresentation() throws {
        let data = try testImage.representation(using: .tiff)
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
        XCTAssertTrue(NSImage(data: data) != nil)
    }
    
    func testBMPRepresentation() throws {
        let data = try testImage.representation(using: .bmp)
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
        XCTAssertTrue(NSImage(data: data) != nil)
    }
    
    // MARK: - Error Tests
    
    func testConversionFailure() {
        let invalidImage = NSImage()
        XCTAssertThrowsError(try invalidImage.representation(using: .png)) { error in
            XCTAssertTrue(error is ImageFormatError)
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyImage() {
        let emptyImage = NSImage(size: .zero)
        XCTAssertThrowsError(try emptyImage.representation(using: .png)) { error in
            XCTAssertTrue(error is ImageFormatError)
        }
    }
    
    func testLargeImage() {
        let largeImage = createTestImage(size: NSSize(width: 1000, height: 1000))
        XCTAssertNoThrow(try largeImage.representation(using: .png))
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.red.drawSwatch(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
} 