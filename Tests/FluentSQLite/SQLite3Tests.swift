import XCTest

import Fluent
@testable import FluentSQLite

class SQLite3Tests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is seriously wrong.")
    }
}