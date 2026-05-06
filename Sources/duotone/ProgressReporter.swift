//
//  ProgressReporter.swift
//  duotone
//

import Foundation

struct ProgressReporter {
    static let defaultMaxFilenameLength = 30
    static let defaultBarWidth = 20

    private static let clearLineEscape = "\r\u{1B}[2K"

    let total: Int
    let isInteractive: Bool
    let barWidth: Int
    private let writer: (String) -> Void

    init(
        total: Int,
        isInteractive: Bool,
        barWidth: Int = ProgressReporter.defaultBarWidth,
        writer: @escaping (String) -> Void
    ) {
        self.total = total
        self.isInteractive = isInteractive
        self.barWidth = barWidth
        self.writer = writer
    }

    func update(current: Int, filename: String) {
        guard self.isInteractive else { return }
        let bar = Self.renderBar(current: current, total: self.total, filename: filename, barWidth: self.barWidth)
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

    static func renderBar(current: Int, total: Int, filename: String, barWidth: Int) -> String {
        let progress = total > 0 ? min(1.0, max(0.0, Double(current) / Double(total))) : 0.0
        let filled = min(barWidth, max(0, Int((Double(barWidth) * progress).rounded())))
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: barWidth - filled)
        let percent = Int((progress * 100).rounded())
        let label = Self.truncate(filename, max: Self.defaultMaxFilenameLength)
        return "[\(bar)] \(current)/\(total) (\(percent)%) \(label)"
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
