#if os(Linux)

import XCTest
@testable import FluentSQLiteTestSuite

XCTMain([
    testCase(SQLite3Tests.allTests),
])

#endif