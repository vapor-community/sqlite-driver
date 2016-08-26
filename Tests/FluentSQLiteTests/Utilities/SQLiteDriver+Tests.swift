
import FluentSQLite
import XCTest
import Foundation

extension SQLiteDriver {
    static func makeTestConnection() -> SQLiteDriver {
        do {
            let driver = try SQLiteDriver(path:"database.db")
            return driver
        } catch {
            XCTFail("Could not create driver")
            fatalError("Could not create driver : \(error)")
        }
    }
}
