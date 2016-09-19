import Fluent
import SQLite

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
    public enum Error: Swift.Error {
        case unsupported(String)
    }

    /**
        Executes the query.
    */
    @discardableResult
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {
        let serializer = GeneralSQLSerializer(sql: query.sql)
        let (statement, values) = serializer.serialize()
        let results = try database.execute(statement) { statement in
            try self.bind(statement: statement, to: values)
        }

        if let id = database.lastId, query.action == .create {
            return try id.makeNode()
        } else {
            return map(results: results)
        }
    }

    public func schema(_ schema: Schema) throws {
      let serializer = GeneralSQLSerializer(sql: schema.sql)
      let (statement, values) = serializer.serialize()
      try _ = raw(statement, values)
    }

    /**
        Executes a raw query with an
        optional array of paramterized
        values and returns the results.
    */
    public func raw(_ statement: String, _ values: [Node] = []) throws -> Node {
        let results = try database.execute(statement) { statement in
            try self.bind(statement: statement, to: values)
        }
        return map(results: results)
    }

    /**
        Binds an array of values to the
        SQLite statement.
    */
    func bind(statement: SQLite.Statement, to values: [Node]) throws {
        for value in values {
            switch value {
            case .number(let number):
                switch number {
                case .int(let int):
                    try statement.bind(int)
                case .double(let double):
                    try statement.bind(double)
                case .uint(let uint):
                    try statement.bind(Int(uint))
                }
            case .string(let string):
                try statement.bind(string)
            case .array(_):
                throw Error.unsupported("Array values not supported.")
            case .object(_):
                throw Error.unsupported("Dictionary values not supported.")
            case .null:
                try statement.null()
            case .bool(let bool):
                try statement.bind(bool)
            case .bytes(let data):
                try statement.bind(String(describing: data))
            }
        }
    }

    /**
        Maps SQLite Results to Fluent results.
    */
    func map(results: [SQLite.Result.Row]) -> Node {
        let res: [Node] = results.map { row in
            var object: Node = .object([:])
            for (key, value) in row.data {
                object[key] = value.makeNode()
            }
            return object
        }
        return .array(res)
    }

}
