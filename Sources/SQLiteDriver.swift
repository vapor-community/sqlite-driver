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
        
        print("SQLite executing: \(sql.statement)")
        let results = try database.execute(sql.statement) { preparer in
            try self.bind(preparer: preparer, to: sql.values)
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
        let results = try database.execute(statement) { preparer in
            try self.bind(preparer: preparer, to: values)
        }
        return map(results: results)
    }

    func bind(preparer: SQLite, to values: [Value]) throws {
        for value in values {
            switch value.structuredData {
            case .int(let int):
                try preparer.bind(int)
            case .double(let double):
                try preparer.bind(double)
            case .string(let string):
                try preparer.bind(string)
            case .array(_):
                throw Error.unsupported("Array values not supported.")
            case .dictionary(_):
                throw Error.unsupported("Dictionary values not supported.")
            case .null: break
            case .bool(let bool):
                try preparer.bind(bool)
            case .data(let data):
                try preparer.bind(String(data))
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
