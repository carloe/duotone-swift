//
//  ProgressReporter.swift
//  duotone
//

import Darwin
import Foundation

struct ProgressReporter: Sendable {
    static let defaultMaxFilenameLength = 30
    static let defaultBarWidth = 20
    static let defaultMaxLineWidth = 80
    /// Filename is dropped entirely when its budget falls below this — leaves the bar legible.
    static let minFilenameBudget = 4

    private static let clearLineEscape = "\r\u{1B}[2K"

    let total: Int
    let isInteractive: Bool
    let barWidth: Int
    let lineWidth: Int
    private let writer: @Sendable (String) -> Void

    init(
        total: Int,
        isInteractive: Bool,
        barWidth: Int = ProgressReporter.defaultBarWidth,
        lineWidth: Int = ProgressReporter.defaultMaxLineWidth,
        writer: @Sendable @escaping (String) -> Void
    ) {
        self.total = total
        self.isInteractive = isInteractive
        self.barWidth = barWidth
        self.lineWidth = lineWidth
        self.writer = writer
    }

    func update(current: Int, filename: String) {
        guard self.isInteractive else { return }
        let bar = Self.renderBar(
            current: current,
            total: self.total,
            filename: filename,
            barWidth: self.barWidth,
            maxLineWidth: self.lineWidth
        )
        self.writer(Self.clearLineEscape + bar)
    }

    func finish(succeeded: Int, skipped: Int, elapsed: TimeInterval) {
        guard self.isInteractive else { return }
        let summary = Self.renderSummary(succeeded: succeeded, skipped: skipped, elapsed: elapsed)
        self.writer(Self.clearLineEscape + summary + "\n")
    }

    func clearLine() {
        guard self.isInteractive else { return }
        self.writer(Self.clearLineEscape)
    }

    static func renderBar(
        current: Int,
        total: Int,
        filename: String,
        barWidth: Int,
        maxLineWidth: Int = ProgressReporter.defaultMaxLineWidth
    ) -> String {
        let progress = total > 0 ? min(1.0, max(0.0, Double(current) / Double(total))) : 0.0
        let filled = min(barWidth, max(0, Int((Double(barWidth) * progress).rounded())))
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barWidth - filled)
        let percent = Int((progress * 100).rounded())
        let chrome = "[\(bar)] \(current)/\(total) (\(percent)%)"
        let budget = maxLineWidth - chrome.count - 1   // -1 for the space before the filename
        if budget < Self.minFilenameBudget {
            return chrome
        }
        let label = Self.truncate(filename, max: min(budget, Self.defaultMaxFilenameLength))
        return "\(chrome) \(label)"
    }

    /// Detects the current terminal width via `ioctl(TIOCGWINSZ)` on stderr.
    /// Falls back to `defaultMaxLineWidth` when stderr is not a TTY or the call fails.
    static func terminalWidth() -> Int {
        var size = winsize()
        let result = withUnsafeMutablePointer(to: &size) { ptr in
            return ioctl(fileno(stderr), TIOCGWINSZ, ptr)
        }
        guard result == 0, size.ws_col > 0 else { return Self.defaultMaxLineWidth }
        return Int(size.ws_col)
    }

    /// Whether a progress bar should be drawn for this run.
    /// Centralizes the four gating conditions so they can be unit-tested in isolation.
    static func shouldShow(total: Int, verbose: Bool, noProgress: Bool, isStderrTTY: Bool) -> Bool {
        return total > 1 && !verbose && !noProgress && isStderrTTY
    }

    /// Returns true when stderr is connected to an interactive terminal.
    static func isStderrInteractive() -> Bool {
        return isatty(fileno(stderr)) != 0
    }

    static func renderSummary(succeeded: Int, skipped: Int, elapsed: TimeInterval) -> String {
        let totalCount = succeeded + skipped
        let elapsedStr = String(format: "%.2fs", elapsed)
        if skipped > 0 {
            return "✓ Processed \(succeeded)/\(totalCount) (\(skipped) skipped) in \(elapsedStr)"
        }
        return "✓ Processed \(succeeded)/\(totalCount) in \(elapsedStr)"
    }

    private static func truncate(_ value: String, max maxLength: Int) -> String {
        guard value.count > maxLength else { return value }
        return "…" + String(value.suffix(maxLength - 1))
    }
}
