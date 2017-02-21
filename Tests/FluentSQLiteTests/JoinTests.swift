import XCTest
@testable import FluentSQLite
import Fluent
@testable import FluentTester

class JoinTests: XCTestCase {
    static let allTests = [
        ("testBasic", testBasic)
    ]

    var database: Fluent.Database!
    var driver: SQLiteDriver!

    override func setUp() {
        driver = SQLiteDriver.makeTestConnection()
        database = Database(driver)
    }

    func testBasic() throws {
        try Atom.revert(database)
        try Compound.revert(database)
        try Pivot<Atom, Compound>.revert(database)

        try Atom.prepare(database)
        try Compound.prepare(database)
        try Pivot<Atom, Compound>.prepare(database)

        Atom.database = database
        Compound.database = database
        Pivot<Atom, Compound>.database = database

        let hydrogen = Atom(id: nil, name: "Hydrogen", protons: 1, weight: 1.00794)
        try hydrogen.save()

        let water = Compound(id: nil, name: "Water")
        try water.save()
        let hydrogenWater = try Pivot(hydrogen, water)
        try hydrogenWater.save()

        let sugar = Compound(id: nil, name: "Sugar")
        try sugar.save()
        let hydrogenSugar = try Pivot(hydrogen, sugar)
        try hydrogenSugar.save()


        let compounds = try hydrogen.compounds.all()
        XCTAssertEqual(compounds.count, 2)
        XCTAssertEqual(compounds.first?.name.string, water.name.string)
        XCTAssertEqual(compounds.last?.id?.int, sugar.id?.int)
    }
}
