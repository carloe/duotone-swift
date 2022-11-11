import XCTest
@testable import duotone

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FileFormatTests.allTests),
        testCase(HexColorTests.allTests)
    ]
}
#endif
