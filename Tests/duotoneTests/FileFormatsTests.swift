//
//  FileFormatsTests.swift
//  duotoneTests
//
//  Created by Carlo Eugster on 16.06.20.
//

import XCTest
@testable import duotone

final class FileFormatsTests: XCTestCase {
    
    // MARK: - Case Tests
    
    func testAllCases() {
        let expectedCases: [FileFormat] = [.png, .jpg, .tiff, .bmp]
        XCTAssertEqual(FileFormat.allCases.count, expectedCases.count)
        
        for expectedCase in expectedCases {
            XCTAssertTrue(FileFormat.allCases.contains(expectedCase))
        }
    }
    
    // MARK: - Static Property Tests
    
    func testAllValidExtensions() {
        let allExtensions = FileFormat.allValidExtensions
        let expectedExtensions = ["png", "jpg", "jpeg", "tiff", "tif", "bmp"]
        
        XCTAssertEqual(allExtensions.sorted(), expectedExtensions.sorted())
        
        // Verify no duplicates
        XCTAssertEqual(allExtensions.count, Set(allExtensions).count)
    }
    
    // MARK: - Property Tests
    
    func testFileExtensions() {
        XCTAssertEqual(FileFormat.png.fileExtension, "png")
        XCTAssertEqual(FileFormat.jpg.fileExtension, "jpg")
        XCTAssertEqual(FileFormat.tiff.fileExtension, "tiff")
        XCTAssertEqual(FileFormat.bmp.fileExtension, "bmp")
    }
    
    func testValidExtensions() {
        XCTAssertEqual(FileFormat.png.validExtensions, ["png"])
        XCTAssertEqual(FileFormat.jpg.validExtensions, ["jpg", "jpeg"])
        XCTAssertEqual(FileFormat.tiff.validExtensions, ["tiff", "tif"])
        XCTAssertEqual(FileFormat.bmp.validExtensions, ["bmp"])
    }
    
    func testRepresentationFormat() {
        XCTAssertEqual(FileFormat.png.representationFormat, .png)
        XCTAssertEqual(FileFormat.jpg.representationFormat, .jpeg)
        XCTAssertEqual(FileFormat.tiff.representationFormat, .tiff)
        XCTAssertEqual(FileFormat.bmp.representationFormat, .bmp)
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationWithPrimaryExtensions() {
        XCTAssertEqual(FileFormat(rawValue: "png"), .png)
        XCTAssertEqual(FileFormat(rawValue: "jpg"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "tiff"), .tiff)
        XCTAssertEqual(FileFormat(rawValue: "bmp"), .bmp)
    }
    
    func testInitializationWithAlternativeExtensions() {
        XCTAssertEqual(FileFormat(rawValue: "jpeg"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "tif"), .tiff)
    }
    
    func testInitializationWithUppercasedExtension() {
        XCTAssertEqual(FileFormat(rawValue: "PNG"), .png)
        XCTAssertEqual(FileFormat(rawValue: "JPG"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "JPEG"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "TIFF"), .tiff)
        XCTAssertEqual(FileFormat(rawValue: "TIF"), .tiff)
        XCTAssertEqual(FileFormat(rawValue: "BMP"), .bmp)
    }
    
    func testInitializationWithInvalidExtension() {
        XCTAssertNil(FileFormat(rawValue: ""))
        XCTAssertNil(FileFormat(rawValue: "invalid"))
        XCTAssertNil(FileFormat(rawValue: "gif"))
        XCTAssertNil(FileFormat(rawValue: "webp"))
    }
    
    // MARK: - Edge Cases
    
    func testInitializationWithMixedCase() {
        XCTAssertEqual(FileFormat(rawValue: "PnG"), .png)
        XCTAssertEqual(FileFormat(rawValue: "JpEg"), .jpg)
        XCTAssertEqual(FileFormat(rawValue: "TiFf"), .tiff)
        XCTAssertEqual(FileFormat(rawValue: "BmP"), .bmp)
    }
    
    func testInitializationWithWhitespace() {
        XCTAssertNil(FileFormat(rawValue: " png"))
        XCTAssertNil(FileFormat(rawValue: "jpg "))
        XCTAssertNil(FileFormat(rawValue: " tiff "))
    }
} 