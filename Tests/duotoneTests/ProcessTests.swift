//
//  ProcessTests.swift
//  duotoneTests
//

import XCTest
@testable import duotone

class ProcessTests: XCTestCase {

    // Required args (inputPath, --out) are passed but unused by resolvePreset(from:).
    private func parseProcess(_ extra: [String]) throws -> Duotone.Process {
        try Duotone.Process.parse(["dummy.jpg", "--out", "out"] + extra)
    }

    // MARK: Named preset

    func testResolvePreset_namedPresetFound() throws {
        let pool = [
            Preset(name: "spacegray", light: "#444644", dark: "#1E201E", contrast: 0.5, blend: 1.0, description: nil),
            Preset(name: "duke", light: "#FFCB00", dark: "#38046C", contrast: 0.4, blend: 0.75, description: nil)
        ]
        let process = try self.parseProcess(["-p", "duke"])
        let resolved = try process.resolvePreset(from: pool)
        XCTAssertEqual(resolved.name, "duke")
        XCTAssertEqual(resolved.contrast, 0.4)
        XCTAssertEqual(resolved.blend, 0.75)
    }

    func testResolvePreset_namedPresetNotFound_throws() throws {
        let process = try self.parseProcess(["-p", "missing"])
        XCTAssertThrowsError(try process.resolvePreset(from: []))
    }

    func testResolvePreset_namedPresetNotFoundInNonEmptyPool_throws() throws {
        let pool = [Preset(name: "duke", light: "#FFCB00", dark: "#38046C", contrast: 0.5, blend: 1.0, description: nil)]
        let process = try self.parseProcess(["-p", "missing"])
        XCTAssertThrowsError(try process.resolvePreset(from: pool))
    }

    // MARK: CLI hex path

    func testResolvePreset_cliHex_defaultsContrastAndBlend() throws {
        let process = try self.parseProcess(["-l", "#FFFFFF", "-d", "#000000"])
        let resolved = try process.resolvePreset(from: [])
        XCTAssertEqual(resolved.name, "cli")
        XCTAssertEqual(resolved.light, "#FFFFFF")
        XCTAssertEqual(resolved.dark, "#000000")
        XCTAssertEqual(resolved.contrast, 0.5)
        XCTAssertEqual(resolved.blend, 1.0)
    }

    func testResolvePreset_cliHex_explicitContrastAndBlend() throws {
        let process = try self.parseProcess([
            "-l", "#FFFFFF",
            "-d", "#000000",
            "-c", "0.25",
            "-b", "0.75"
        ])
        let resolved = try process.resolvePreset(from: [])
        XCTAssertEqual(resolved.contrast, 0.25)
        XCTAssertEqual(resolved.blend, 0.75)
    }

    func testResolvePreset_cliHex_clampsContrastAndBlend() throws {
        let process = try self.parseProcess([
            "-l", "#FFFFFF",
            "-d", "#000000",
            "--contrast=2.0",
            "--blend=-1.0"
        ])
        let resolved = try process.resolvePreset(from: [])
        XCTAssertEqual(resolved.contrast, 1.0)
        XCTAssertEqual(resolved.blend, 0.0)
    }

    func testResolvePreset_cliHex_missingLight_throws() throws {
        let process = try self.parseProcess(["-d", "#000000"])
        XCTAssertThrowsError(try process.resolvePreset(from: []))
    }

    func testResolvePreset_cliHex_missingDark_throws() throws {
        let process = try self.parseProcess(["-l", "#FFFFFF"])
        XCTAssertThrowsError(try process.resolvePreset(from: []))
    }
}
