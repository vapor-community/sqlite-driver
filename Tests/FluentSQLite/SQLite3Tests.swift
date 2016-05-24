import XCTest

import Fluent
@testable import FluentSQLite

class SQLite3Tests: XCTestCase {
    static var allTests : [(String, SQLite3Tests -> () throws -> Void)] {
        return [
            ("testBasicSelect", testBasicSelect),
        ]
    }

    final class User: Model {
        var id: Value?

        func serialize() -> [String: Value?] {
            return [:]
        }

        init?(serialized: [String: Value]) {

        }
    }

    var driver: SQLiteDriver!
    var database: Database!

    override func setUp() {


        driver = try! SQLiteDriver(path: "Tests/test.sqlite")
        database = Database(driver: driver)
        Database.default = database
    }

    func testBasicSelect() {
        let token = "500D4770-9720-44DF-A25E-F29689DA521D"
        do {
            let user = try User.query.filter("token", token).first()
            XCTAssert(user?.id?.string == "1", "Correct User not found")
        } catch {
            XCTFail("Could not query: \(error)")
        }
    }
}