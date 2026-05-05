//
//  ClampedTests.swift
//  duotoneTests
//

import XCTest
@testable import duotone

class ClampedTests: XCTestCase {

    func testClampedReturnsValueWhenWithinRange() {
        XCTAssertEqual(0.5.clamped(to: 0.0...1.0), 0.5)
    }

    func testClampedReturnsLowerBoundWhenBelow() {
        XCTAssertEqual((-0.25).clamped(to: 0.0...1.0), 0.0)
    }

    func testClampedReturnsUpperBoundWhenAbove() {
        XCTAssertEqual(1.75.clamped(to: 0.0...1.0), 1.0)
    }

    func testClampedAtBoundsReturnsBounds() {
        XCTAssertEqual(0.0.clamped(to: 0.0...1.0), 0.0)
        XCTAssertEqual(1.0.clamped(to: 0.0...1.0), 1.0)
    }

    func testClampedWorksForIntegers() {
        XCTAssertEqual(5.clamped(to: 0...10), 5)
        XCTAssertEqual((-3).clamped(to: 0...10), 0)
        XCTAssertEqual(99.clamped(to: 0...10), 10)
    }
}
