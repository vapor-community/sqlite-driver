import Fluent
import SQLite

public class SQLiteDriver: Fluent.Driver, Connection {

    public var idKey: String = "id"
    public var idType: IdentifierType = .int

    public var closed: Bool {
        // TODO: FIXME
        return false
    }

    let database: SQLite

    /**
        Creates a new SQLiteDriver pointing
        to the database at the supplied path.
    */
    public init(path: String = "Database/main.sqlite") throws {
        database = try SQLite(path: path)
    }

    private init(database: SQLite) {
        self.database = database
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
        let serializer = SQLiteSerializer(sql: query.sql)
        let (statement, values) = serializer.serialize()
        let results = try database.execute(statement) { statement in
            try self.bind(statement: statement, to: values)
        }

        if let id = database.lastId, query.action == .create {
            return try id.makeNode()
        } else if query.action == .count {
            guard let (_, value) = results.first?.data.first,
                let count = Int(value) else {
                return .number(.int(0))
            }
            return .number(.int(count))
        } else {
            return map(results: results)
        }
    }

    public func schema(_ schema: Schema) throws {
      let serializer = SQLiteSerializer(sql: schema.sql)
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
            case .date(let date):
                let dateString = Date.outgoingDateFormatter.string(from: date)
                try statement.bind(dateString)
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

    public func makeConnection() throws -> Connection {
        return SQLiteDriver(database: database)
    }
}
