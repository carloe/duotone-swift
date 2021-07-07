import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FileFormatTests.allTests),
        testCase(HexColorTests.allTests)
    ]
}
#endif
