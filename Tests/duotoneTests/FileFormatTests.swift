//
//  FileFormatTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 07.07.21.
//

import AppKit
import XCTest
@testable import duotone

class FileFormatTests: XCTestCase {

    private func makeTestImage(width: Int = 8, height: Int = 8) -> NSImage {
        let image = NSImage(size: NSSize(width: width, height: height))
        image.lockFocus()
        NSColor.red.setFill()
        NSRect(x: 0, y: 0, width: width, height: height).fill()
        image.unlockFocus()
        return image
    }

    // MARK: Initializing

    func testInitializingWithJPEG() throws {
        XCTAssertEqual(FileFormat(rawValue: "jpg"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "jpeg"), .jpg)
    }

    func testInitializingWithTIFF() throws {
        XCTAssertEqual(FileFormat(rawValue: "tiff"), .tiff)
        XCTAssertEqual(FileFormat(rawValue: "tif"), .tiff)
    }

    func testInitializingWithPNG() throws {
        XCTAssertEqual(FileFormat(rawValue: "png"), .png)
    }

    func testInitializingWithBMP() throws {
        XCTAssertEqual(FileFormat(rawValue: "bmp"), .bmp)
    }

    func testInitializingWithInvalidExtension() throws {
        XCTAssertNil(FileFormat(rawValue: "hello"))
    }

    func testInitializingWithUppercasedExtension() throws {
        XCTAssertEqual(FileFormat(rawValue: "JpEg"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "TIFF"), .tiff)
    }

    // MARK: File Extensions

    func testReturnedFileExtensions() throws {
        XCTAssertEqual(FileFormat.png.fileExtension, "png")
        XCTAssertEqual(FileFormat.tiff.fileExtension, "tiff")
        XCTAssertEqual(FileFormat.bmp.fileExtension, "bmp")
        XCTAssertEqual(FileFormat.jpg.fileExtension, "jpg")
    }

    // MARK: Image Representation

    private func assertRoundTrip(format: FileFormat, file: StaticString = #filePath, line: UInt = #line) throws {
        let image = makeTestImage()
        let data = try XCTUnwrap(image.imageRepresentation(for: format) as Data?, "no data produced for \(format)", file: file, line: line)
        XCTAssertGreaterThan(data.count, 0, "\(format) data is empty", file: file, line: line)

        let decoded = try XCTUnwrap(NSImage(data: data), "could not decode \(format) data", file: file, line: line)
        // Use pixel-level dimensions rather than NSImage.size: BMP doesn't carry DPI
        // metadata so NSImage reports it in raw pixels while PNG/JPEG/TIFF report points.
        let rep = try XCTUnwrap(decoded.representations.first as? NSBitmapImageRep, "no bitmap rep for \(format)", file: file, line: line)
        XCTAssertGreaterThan(rep.pixelsWide, 0, file: file, line: line)
        XCTAssertGreaterThan(rep.pixelsHigh, 0, file: file, line: line)
    }

    func testImageRepresentation_roundTripsPNG() throws {
        try assertRoundTrip(format: .png)
    }

    func testImageRepresentation_roundTripsJPEG() throws {
        try assertRoundTrip(format: .jpg)
    }

    func testImageRepresentation_roundTripsTIFF() throws {
        try assertRoundTrip(format: .tiff)
    }

    func testImageRepresentation_roundTripsBMP() throws {
        try assertRoundTrip(format: .bmp)
    }
}
