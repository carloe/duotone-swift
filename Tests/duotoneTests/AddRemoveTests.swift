//
//  AddRemoveTests.swift
//  duotoneTests
//

import XCTest
@testable import duotone

class AddRemoveTests: XCTestCase {

    // MARK: Add

    func testAdd_appendsPresetToEmptyList() throws {
        let add = try Duotone.Add.parse([
            "--preset", "spacegray",
            "-l", "#444644",
            "-d", "#1E201E"
        ])
        let updated = try add.addingPreset(to: [])
        XCTAssertEqual(updated.count, 1)
        XCTAssertEqual(updated[0].name, "spacegray")
        XCTAssertEqual(updated[0].light, "#444644")
        XCTAssertEqual(updated[0].dark, "#1E201E")
        XCTAssertEqual(updated[0].contrast, 0.5) // default
        XCTAssertEqual(updated[0].blend, 1.0)    // default
        XCTAssertNil(updated[0].description)
    }

    func testAdd_appendsToNonEmptyList() throws {
        let existing = [Preset(name: "duke", light: "#FFCB00", dark: "#38046C", contrast: 0.5, blend: 1.0, description: nil)]
        let add = try Duotone.Add.parse([
            "--preset", "spacegray",
            "-l", "#444644",
            "-d", "#1E201E"
        ])
        let updated = try add.addingPreset(to: existing)
        XCTAssertEqual(updated.count, 2)
        XCTAssertEqual(updated[0].name, "duke")
        XCTAssertEqual(updated[1].name, "spacegray")
    }

    func testAdd_throwsWhenNameAlreadyExists() throws {
        let existing = [Preset(name: "spacegray", light: "#444644", dark: "#1E201E", contrast: 0.5, blend: 1.0, description: nil)]
        let add = try Duotone.Add.parse([
            "--preset", "spacegray",
            "-l", "#FFFFFF",
            "-d", "#000000"
        ])
        XCTAssertThrowsError(try add.addingPreset(to: existing))
    }

    func testAdd_clampsContrastAndBlend() throws {
        let add = try Duotone.Add.parse([
            "--preset", "x",
            "-l", "#FFFFFF",
            "-d", "#000000",
            "--contrast=1.5",
            "--blend=-0.25"
        ])
        let updated = try add.addingPreset(to: [])
        XCTAssertEqual(updated[0].contrast, 1.0)
        XCTAssertEqual(updated[0].blend, 0.0)
    }

    func testAdd_persistsDescription() throws {
        let add = try Duotone.Add.parse([
            "--preset", "duke",
            "-l", "#FFCB00",
            "-d", "#38046C",
            "--description", "duke nukem"
        ])
        let updated = try add.addingPreset(to: [])
        XCTAssertEqual(updated[0].description, "duke nukem")
    }

    func testAdd_throwsOnInvalidLightHex() throws {
        let add = try Duotone.Add.parse([
            "--preset", "x",
            "-l", "not-a-hex",
            "-d", "#000000"
        ])
        XCTAssertThrowsError(try add.addingPreset(to: []))
    }

    // MARK: Remove

    func testRemove_filtersMatchingName() throws {
        let existing = [
            Preset(name: "a", light: "#FFFFFF", dark: "#000000", contrast: 0.5, blend: 1.0, description: nil),
            Preset(name: "b", light: "#FF0000", dark: "#00FF00", contrast: 0.5, blend: 1.0, description: nil)
        ]
        let remove = try Duotone.Remove.parse(["--preset", "a"])
        let filtered = try remove.removingPreset(from: existing)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].name, "b")
    }

    func testRemove_throwsWhenNameNotFound() throws {
        let existing = [Preset(name: "a", light: "#FFFFFF", dark: "#000000", contrast: 0.5, blend: 1.0, description: nil)]
        let remove = try Duotone.Remove.parse(["--preset", "missing"])
        XCTAssertThrowsError(try remove.removingPreset(from: existing))
    }

    func testRemove_throwsOnEmptyList() throws {
        let remove = try Duotone.Remove.parse(["--preset", "anything"])
        XCTAssertThrowsError(try remove.removingPreset(from: []))
    }
}
