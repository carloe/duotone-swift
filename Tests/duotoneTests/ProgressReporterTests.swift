//
//  ProgressReporterTests.swift
//  duotoneTests
//

import XCTest
@testable import duotone

final class ProgressReporterTests: XCTestCase {

    // MARK: renderBar — fill levels

    func testRenderBar_atZeroProgress_isEmpty() {
        let bar = ProgressReporter.renderBar(current: 0, total: 10, filename: "a.png", barWidth: 10)
        XCTAssertTrue(bar.contains("[" + String(repeating: "░", count: 10) + "]"), bar)
        XCTAssertTrue(bar.contains("0/10"), bar)
        XCTAssertTrue(bar.contains("(0%)"), bar)
    }

    func testRenderBar_atHalfProgress_isHalfFilled() {
        let bar = ProgressReporter.renderBar(current: 5, total: 10, filename: "a.png", barWidth: 10)
        let expected = "[" + String(repeating: "█", count: 5) + String(repeating: "░", count: 5) + "]"
        XCTAssertTrue(bar.contains(expected), bar)
        XCTAssertTrue(bar.contains("5/10"), bar)
        XCTAssertTrue(bar.contains("(50%)"), bar)
    }

    func testRenderBar_atFullProgress_isFullyFilled() {
        let bar = ProgressReporter.renderBar(current: 10, total: 10, filename: "a.png", barWidth: 10)
        XCTAssertTrue(bar.contains("[" + String(repeating: "█", count: 10) + "]"), bar)
        XCTAssertTrue(bar.contains("10/10"), bar)
        XCTAssertTrue(bar.contains("(100%)"), bar)
    }

    // MARK: renderBar — edge cases

    func testRenderBar_zeroTotal_doesNotCrash() {
        let bar = ProgressReporter.renderBar(current: 0, total: 0, filename: "a.png", barWidth: 10)
        XCTAssertTrue(bar.contains("0/0"), bar)
        XCTAssertTrue(bar.contains("(0%)"), bar)
    }

    func testRenderBar_includesFilename_whenShort() {
        let bar = ProgressReporter.renderBar(current: 1, total: 2, filename: "snapshot.png", barWidth: 10)
        XCTAssertTrue(bar.contains("snapshot.png"), bar)
    }

    func testRenderBar_longFilename_isSuffixTruncatedWithLeadingEllipsis() {
        let long = String(repeating: "x", count: 50) + "tail.jpg"
        let bar = ProgressReporter.renderBar(current: 1, total: 2, filename: long, barWidth: 10)
        XCTAssertFalse(bar.contains(long), "full long name should not appear in: \(bar)")
        XCTAssertTrue(bar.contains("…"), "expected leading ellipsis in: \(bar)")
        XCTAssertTrue(bar.contains("tail.jpg"), "expected suffix to be preserved in: \(bar)")
    }

    // MARK: renderSummary

    func testRenderSummary_noSkipped_omitsSkippedClause() {
        let line = ProgressReporter.renderSummary(succeeded: 10, skipped: 0, elapsed: 1.234)
        XCTAssertTrue(line.contains("✓"), line)
        XCTAssertTrue(line.contains("10/10"), line)
        XCTAssertFalse(line.contains("skipped"), line)
    }

    func testRenderSummary_withSkipped_includesSkippedClause() {
        let line = ProgressReporter.renderSummary(succeeded: 8, skipped: 2, elapsed: 1.234)
        XCTAssertTrue(line.contains("8/10"), line)
        XCTAssertTrue(line.contains("(2 skipped)"), line)
    }

    func testRenderSummary_formatsElapsedToTwoDecimals() {
        let line = ProgressReporter.renderSummary(succeeded: 1, skipped: 0, elapsed: 4.207)
        XCTAssertTrue(line.contains("4.21s"), line)
    }

    // MARK: Reporter — interactive vs not

    private final class CaptureWriter {
        var output: String = ""
        func write(_ value: String) { self.output.append(value) }
    }

    func testReporter_whenNotInteractive_writerIsNeverCalled() {
        let capture = CaptureWriter()
        let reporter = ProgressReporter(total: 5, isInteractive: false, barWidth: 10, writer: capture.write)
        reporter.update(current: 1, filename: "a.png")
        reporter.update(current: 2, filename: "b.png")
        reporter.finish(succeeded: 2, skipped: 0, elapsed: 0.5)
        XCTAssertEqual(capture.output, "")
    }

    func testReporter_whenInteractive_updateWritesCarriageReturnAndBar() {
        let capture = CaptureWriter()
        let reporter = ProgressReporter(total: 4, isInteractive: true, barWidth: 4, writer: capture.write)
        reporter.update(current: 2, filename: "a.png")
        XCTAssertTrue(capture.output.hasPrefix("\r"), capture.output)
        XCTAssertTrue(capture.output.contains("2/4"), capture.output)
        XCTAssertTrue(capture.output.contains("a.png"), capture.output)
    }

    func testReporter_finish_emitsSummaryWithTrailingNewline() {
        let capture = CaptureWriter()
        let reporter = ProgressReporter(total: 5, isInteractive: true, barWidth: 4, writer: capture.write)
        reporter.finish(succeeded: 5, skipped: 0, elapsed: 1.0)
        XCTAssertTrue(capture.output.contains("✓"), capture.output)
        XCTAssertTrue(capture.output.hasSuffix("\n"), capture.output)
    }

    // MARK: clearLine — used when a skip-message must print above the bar

    func testReporter_clearLine_whenInteractive_writesCarriageReturnAndClearEscape() {
        let capture = CaptureWriter()
        let reporter = ProgressReporter(total: 5, isInteractive: true, barWidth: 4, writer: capture.write)
        reporter.clearLine()
        XCTAssertTrue(capture.output.contains("\r"), capture.output)
        XCTAssertTrue(capture.output.contains("\u{1B}[2K"), capture.output)
    }

    func testReporter_clearLine_whenNotInteractive_writesNothing() {
        let capture = CaptureWriter()
        let reporter = ProgressReporter(total: 5, isInteractive: false, barWidth: 4, writer: capture.write)
        reporter.clearLine()
        XCTAssertEqual(capture.output, "")
    }
}
