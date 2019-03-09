import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WebRequestTests.allTests),
    ]
}
#endif