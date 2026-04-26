//
//  LoaderTests.swift
//  duotoneTests
//

import XCTest
@testable import duotone

class LoaderTests: XCTestCase {
    private var tempPath: String = ""

    override func setUp() {
        super.setUp()
        let dir = NSTemporaryDirectory()
        tempPath = "\(dir)duotone-loader-tests-\(UUID().uuidString).json"
    }

    override func tearDown() {
        try? FileManager.default.removeItem(atPath: tempPath)
        super.tearDown()
    }

    func testLoadPresets_whenFileDoesNotExist_returnsEmpty() throws {
        let presets = try Duotone.loadPresets(from: tempPath)
        XCTAssertEqual(presets.count, 0)
    }

    func testSavePresetsAndLoad_roundTrip() throws {
        let original = [
            Preset(name: "spacegray", light: "#444644", dark: "#1E201E", contrast: 0.5, blend: 1.0, description: nil),
            Preset(name: "duke", light: "#FFCB00", dark: "#38046C", contrast: 0.5, blend: 0.75, description: "duke nukem")
        ]
        try Duotone.savePresets(original, to: tempPath)

        let loaded = try Duotone.loadPresets(from: tempPath)
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].name, "spacegray")
        XCTAssertEqual(loaded[0].light, "#444644")
        XCTAssertEqual(loaded[1].name, "duke")
        XCTAssertEqual(loaded[1].description, "duke nukem")
        XCTAssertEqual(loaded[1].blend, 0.75)
    }

    func testSavePresets_overwritesExisting() throws {
        let initial = [Preset(name: "a", light: "#FFFFFF", dark: "#000000", contrast: 0.5, blend: 1.0, description: nil)]
        try Duotone.savePresets(initial, to: tempPath)

        let replacement = [Preset(name: "b", light: "#FF0000", dark: "#00FF00", contrast: 0.25, blend: 0.5, description: nil)]
        try Duotone.savePresets(replacement, to: tempPath)

        let loaded = try Duotone.loadPresets(from: tempPath)
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].name, "b")
    }

    func testSavePresets_whenFileDoesNotExist_createsFile() throws {
        // Regression test for the bug fixed in fd47ebe: savePresets used to throw
        // if the file didn't already exist, which broke the first-ever 'duotone add'.
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempPath))
        try Duotone.savePresets([], to: tempPath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempPath))
    }
}
