//
//  FileFormatTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 07.07.21.
//

import XCTest

class FileFormatTests: XCTestCase {

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
}
