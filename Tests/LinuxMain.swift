#if os(Linux)

import XCTest
@testable import FluentTestSuite

XCTMain([
    testCase(SQLite3Tests.allTests),
])

#endif