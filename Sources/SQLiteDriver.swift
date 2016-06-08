import Fluent

public class SQLiteDriver: Fluent.Driver {

    public var idKey: String = "id"

    let database: SQLite

    /**
        Creates a new SQLiteDriver pointing
        to the database at the supplied path.
    */
    public init(path: String = "Database/main.sqlite") throws {
        database = try SQLite(path: path)
    }

    /**
        Describes the errors this
        driver can throw.
    */
    public enum Error: ErrorProtocol {
        case unsupported(String)
    }
    
    /**
        Executes the query.
    */
    public func execute<T: Model>(_ query: Query<T>) throws -> [[String: Value]] {
        let sql = SQL(query: query)
        
        // print("SQLite executing: \(sql.statement)") // useful for developing
        let results = try database.execute(sql.statement) { statement in
            try self.bind(statement: statement, to: sql.values)
        }

        if query.action == .create {
            return [
               [idKey : database.lastId]
            ]
        } else {
            return map(results: results)
        }
    }

    /**
        Executes a raw query with an 
        optional array of paramterized
        values and returns the results.
    */
    public func raw(_ statement: String, values: [Value] = []) throws -> [[String: Value]] {
        let results = try database.execute(statement) { statement in
            try self.bind(statement: statement, to: values)
        }
        return map(results: results)
    }

    func bind(statement: SQLite.Statement, to values: [Value]) throws {
        for value in values {
            switch value.structuredData {
            case .int(let int):
                try statement.bind(int)
            case .double(let double):
                try statement.bind(double)
            case .string(let string):
                try statement.bind(string)
            case .array(_):
                throw Error.unsupported("Array values not supported.")
            case .dictionary(_):
                throw Error.unsupported("Dictionary values not supported.")
            case .null: break
            case .bool(let bool):
                try statement.bind(bool)
            case .data(let data):
                try statement.bind(String(data))
            }
        }
    }

    func map(results: [SQLite.Result.Row]) -> [[String: Value]] {
        return results.map { row in
            var data: [String: Value] = [:]
            row.data.forEach { key, val in
                data[key] = val
            }
            return data
        }
    }

}
