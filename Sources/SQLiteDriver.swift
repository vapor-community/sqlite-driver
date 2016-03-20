import Fluent

public class SQLiteDriver: Fluent.Driver {
    let database: SQLite!
    
    init() throws {
        self.database = try SQLite()
    }
    
    public func execute<T: Model>(query: Query<T>) throws -> [[String: Value]] {
        let sql = SQL(query: query)
        
        var data: [[String: String]] = []
        let values: [Any] = sql.values.map { return $0.rawValue }
        let results = try self.database.execute(sql.statement, values: values)
        for row in results {
            data.append(row.data)
        }
        
        return []
    }
}