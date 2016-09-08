#if os(Linux)

import XCTest
@testable import FluentSQLiteTests

XCTMain([
    testCase(SQLite3Tests.allTests),
])

#endif