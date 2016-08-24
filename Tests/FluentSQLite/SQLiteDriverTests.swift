import XCTest
@testable import FluentSQLite
@testable import Fluent


class SQLite3Tests: XCTestCase {
    static var allTests: [(String, (SQLite3Tests) -> () throws -> Void)] {
        return [
           ("testSaveAndFind", testSaveAndFind)
        ]
    }
    
    var driver:SQLiteDriver!
    var database:Fluent.Database!


    override func setUp() {
        driver = SQLiteDriver.makeTestConnection()
        database = Database(driver)
    }
    

    func testSaveAndFind() {
        _ = try! driver.raw("DROP TABLE IF EXISTS `posts`")
        do {
            _ = try driver.raw("CREATE TABLE IF NOT EXISTS `posts` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` CHAR(255), `text` CHAR(255))")
        } catch {
            XCTFail("Could not create table \(error)")
        }
//        try! database.create("posts") { creator in
//            creator.id()
//            creator.string("title")
//            creator.string("text")
//        }
        
        var post = Post(id: nil, title: "Vapor & Tests", text: "Lorem ipsum etc...")
        Post.database = database
        
        do {
            try post.save()
            print("Just saved")
        } catch {
            XCTFail("Could not save : \(error)")
        }
        
        do {
            let fetched = try Post.find(1)
            XCTAssertEqual(fetched?.title, post.title)
            XCTAssertEqual(fetched?.text, post.text)
        } catch {
            XCTFail("Could not fetch user : \(error)")
        }
        
        do {
            let post  = try Post.find(2)
            XCTAssertNil(post)
        } catch {
            XCTFail("Could not find post: \(error)")
        }
        
    }
    
}
