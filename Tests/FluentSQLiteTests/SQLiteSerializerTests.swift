import XCTest
@testable import FluentSQLite
@testable import Fluent
import FluentTester

class SQLiteSerializerTests : XCTestCase {
    static let allTests = {
        return [
            ("testSql", testSql)
        ]
    }

    var serializer:SQLiteSerializer!

    func testSql() {
        serializer = SQLiteSerializer(sql: SQL.count(table: "testTable", filters: [], joins: []))
        let (output, nodes) = serializer.serialize()
        XCTAssertEqual(output, "SELECT COUNT(*) as _fluent_count FROM `testTable`")
        XCTAssertEqual(nodes, [])
    }
}
