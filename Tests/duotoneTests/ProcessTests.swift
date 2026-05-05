//
//  ProcessTests.swift
//  duotoneTests
//

import XCTest
@testable import duotone

class ProcessTests: XCTestCase {
    private var tempDir: String = ""

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = "\(NSTemporaryDirectory())duotone-process-tests-\(UUID().uuidString)"
        try FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(atPath: tempDir)
        try super.tearDownWithError()
    }

    private func writeFile(name: String, in dir: String? = nil) throws -> String {
        let parent = dir ?? self.tempDir
        let path = "\(parent)/\(name)"
        try Data().write(to: URL(fileURLWithPath: path))
        return path
    }

    // Required args (inputPath, --out) are passed but unused by resolvePreset(from:).
    private func parseProcess(_ extra: [String]) throws -> Duotone.Process {
        try Duotone.Process.parse(["dummy.jpg", "--out", "out"] + extra)
    }

    private func parseProcess(inputPath: String, _ extra: [String] = []) throws -> Duotone.Process {
        try Duotone.Process.parse([inputPath, "--out", "out"] + extra)
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

    // MARK: processInput

    func testProcessInput_singleFileWithValidExtension_returnsThatFile() throws {
        let path = try self.writeFile(name: "image.png")
        let process = try self.parseProcess(inputPath: path)
        let files = try process.processInput()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files[0].name, "image.png")
    }

    func testProcessInput_singleFileWithJpegAlias_returnsThatFile() throws {
        let path = try self.writeFile(name: "image.jpeg")
        let process = try self.parseProcess(inputPath: path)
        let files = try process.processInput()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files[0].name, "image.jpeg")
    }

    func testProcessInput_singleFileWithUppercaseExtension_returnsThatFile() throws {
        // Regression: real-world camera output uses .JPG (uppercase). The previous
        // implementation matched extensions case-sensitively and rejected these.
        let path = try self.writeFile(name: "image.JPG")
        let process = try self.parseProcess(inputPath: path)
        let files = try process.processInput()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files[0].name, "image.JPG")
    }

    func testProcessInput_folderWithUppercaseExtensions_returnsThoseFiles() throws {
        // Regression: the folder branch silently dropped uppercase-extension files,
        // leaving callers with "No images found" on perfectly valid input.
        _ = try self.writeFile(name: "a.JPG")
        _ = try self.writeFile(name: "b.PNG")
        _ = try self.writeFile(name: "c.TIFF")
        _ = try self.writeFile(name: "ignore.txt")
        let process = try self.parseProcess(inputPath: tempDir)
        let files = try process.processInput()
        let names = Set(files.map(\.name))
        XCTAssertEqual(names, Set(["a.JPG", "b.PNG", "c.TIFF"]))
    }

    func testProcessInput_singleFileWithInvalidExtension_throws() throws {
        let path = try self.writeFile(name: "notes.txt")
        let process = try self.parseProcess(inputPath: path)
        XCTAssertThrowsError(try process.processInput())
    }

    func testProcessInput_folder_returnsOnlyValidFormatFiles() throws {
        _ = try self.writeFile(name: "a.png")
        _ = try self.writeFile(name: "b.jpg")
        _ = try self.writeFile(name: "ignore.txt")
        _ = try self.writeFile(name: "readme.md")
        let process = try self.parseProcess(inputPath: tempDir)
        let files = try process.processInput()
        let names = Set(files.map(\.name))
        XCTAssertEqual(names, Set(["a.png", "b.jpg"]))
    }

    func testProcessInput_folderWithNoSupportedFiles_returnsEmpty() throws {
        _ = try self.writeFile(name: "ignore.txt")
        let process = try self.parseProcess(inputPath: tempDir)
        let files = try process.processInput()
        XCTAssertEqual(files.count, 0)
    }

    func testProcessInput_emptyFolder_returnsEmpty() throws {
        let process = try self.parseProcess(inputPath: tempDir)
        let files = try process.processInput()
        XCTAssertEqual(files.count, 0)
    }

    func testProcessInput_nonExistentPath_throws() throws {
        let process = try self.parseProcess(inputPath: "\(tempDir)/does-not-exist")
        XCTAssertThrowsError(try process.processInput())
    }

    // MARK: Strict flag

    func testStrictFlag_defaultsToFalse() throws {
        let process = try self.parseProcess(["-l", "#FFFFFF", "-d", "#000000"])
        XCTAssertFalse(process.strict)
    }

    func testStrictFlag_setsToTrueWhenPassed() throws {
        let process = try self.parseProcess(["-l", "#FFFFFF", "-d", "#000000", "--strict"])
        XCTAssertTrue(process.strict)
    }
}
