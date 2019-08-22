import XCTest
import WebRequest

class BasicHTTPResultValidatorTests: XCTestCase {

    let subject = BasicHTTPResultValidator()

    func test_isValid_with_2XX_result_returns_true() {
        for i in 200...299 {
            XCTAssertTrue(subject.isValid(WebRequest.Result(status: i)))
        }
    }

    func test_isValid_with_anything_other_than_2XX_result_returns_false() {
        for i in 0...999 where !(200...299 ~= i) {
            XCTAssertFalse(subject.isValid(WebRequest.Result(status: i)))
        }
    }

    func test_isUnauthorized_with_401_result_returns_true() {
        XCTAssertTrue(subject.isUnauthorized(WebRequest.Result(status: 401)))
    }

    func test_isUnauthorized_with_anything_other_than_401_result_returns_false() {
        for i in 0...999 where (401 != i) {
            XCTAssertFalse(subject.isUnauthorized(WebRequest.Result(status: i)))
        }
    }
}
