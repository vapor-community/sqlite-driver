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
        
        var results: [SQLite.Result.Row]

        print("SQLite executing: \(sql.statement)")
        results = try database.execute(sql.statement) { preparer in
            for value in sql.values {
                switch value.structuredData {
                case .integer(let int):
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
                }
            }
        }

        if query.action == .create {
            return [
               [idKey : database.lastId]
            ]
        } else {
            return results.map { row in
                var data: [String: Value] = [:]
                row.data.forEach { key, val in
                    data[key] = val
                }
                return data
            }
        }
    }

}
