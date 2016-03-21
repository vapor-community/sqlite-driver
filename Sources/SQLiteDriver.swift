import Fluent

public class SQLiteDriver: Fluent.Driver {
    let database: SQLite!
    public var databaseFilePath = "Database/main.sqlite"
    
    init() throws {
        self.database = try SQLite(path: self.databaseFilePath)
    }
    
    public func execute<T: Model>(query: Query<T>) throws -> [[String: Value]] {
        let sql = SQL(query: query)
        
        let results: [SQLite.Result.Row]
        if sql.values.count > 0 {
            var position = 1
            results = try self.database.execute(sql.statement) {
                for value in sql.values {
                    if let int = value.int {
                        self.database.bind(Int32(int), position: position)
                    } else if let double = value.double {
                        self.database.bind(double, position: position)
                    } else {
                        self.database.bind(value.string, position: position)
                    }
                    position += 1
                }
            }
            
        } else {
            results = try self.database.execute(sql.statement)
        }
        
        var data: [[String: Value]] = []
        for row in results {
            var t: [String: Value] = [:]
            for (k, v) in row.data {
                t[k] = v as String
            }
            data.append(t)
        }
        
        return data
    }

}
