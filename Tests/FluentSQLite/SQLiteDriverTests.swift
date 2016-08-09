import XCTest
@testable import FluentSQLite
@testable import Fluent


class SQLite3Tests: XCTestCase {
    static var allTests: [(String, (SQLite3Tests) -> () throws -> Void)] {
        return [
           ("testReality", testReality)
        ]
    }

    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is seriously wrong.")
    }
    
    func testBind() {
        let database = Database(SQLiteDriver())
    }
}
