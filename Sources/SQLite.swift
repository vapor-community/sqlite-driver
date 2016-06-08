#if os(Linux)
    import CSQLiteLinux
#else
    import CSQLiteMac
#endif

let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public class SQLite {
    typealias PrepareClosure = ((Statement) throws -> ())
    typealias Database = OpaquePointer

    var database: Database?

    init(path: String) throws {
        let options = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(path, &database, options, nil) != SQLITE_OK {
            throw Error.connection(database?.errorMessage ?? "")
        }
    }

    func close() {
        sqlite3_close(database)
    }

    struct Result {
        struct Row {
            var data: [String: String]

            init() {
                data = [:]
            }
        }

        var rows: [Row]

        init() {
            rows = []
        }
    }

    func execute(_ queryString: String, prepareClosure: PrepareClosure = { _ in }) throws -> [Result.Row] {
        guard let database = self.database else {
            throw Error.execute("No database")
        }
        bindPosition = 0

        let statementContainer = UnsafeMutablePointer<OpaquePointer?>.init(allocatingCapacity: 1)
        defer {
            statementContainer.deallocateCapacity(1)
        }

        if sqlite3_prepare_v2(database, queryString, -1, statementContainer, nil) != SQLITE_OK {
            throw Error.prepare(database.errorMessage)
        }

        guard let statementPointer = statementContainer.pointee else {
            throw Error.execute("Statement pointer errror")
        }

        let statement = Statement(pointer: statementPointer, database: database)
        try prepareClosure(statement)

        var result = Result()
        while sqlite3_step(statement.pointer) == SQLITE_ROW {
            
            var row = Result.Row()
            let count = sqlite3_column_count(statement.pointer)

            for i in 0..<count {
                let text = sqlite3_column_text(statement.pointer, i)
                let name = sqlite3_column_name(statement.pointer, i)

                var value: String? = nil
                if let text = text {
                    value = String(cString: UnsafePointer(text))
                }

                let column: String
                if let name = name {
                    column = String(cString: name)
                } else {
                    column = ""
                }

                row.data[column] = value
            }

            result.rows.append(row)
        }
        
        if sqlite3_finalize(statement.pointer) != SQLITE_OK {
            throw Error.execute(database.errorMessage)
        }
        
        return result.rows
    }

    var lastId: Int {
        let id = sqlite3_last_insert_rowid(database)
        return Int(id)
    }

    //MARK: Error

    public enum Error: ErrorProtocol {
        case connection(String)
        case close(String)
        case prepare(String)
        case bind(String)
        case execute(String)
    }

    //MARK: Bind

    var bindPosition: Int32 = 0
    
    var nextBindPosition: Int32 {
        bindPosition += 1
        return bindPosition
    }
    


}

extension SQLite.Database {
    var errorMessage: String {
        if let raw = sqlite3_errmsg(self) {
            return String(cString: raw) ?? "Unknown"
        } else {
            return "Unknown"
        }
    }

}

extension SQLite {
    class Statement {
        typealias Pointer = OpaquePointer

        var pointer: Pointer
        var database: Database
        var bindPosition: Int32
        var nextBindPosition: Int32 {
            bindPosition += 1
            return bindPosition
        }

        init(pointer: Pointer, database: Database) {
            self.pointer = pointer
            self.database = database
            bindPosition = 0
        }

        func reset(_ statementPointer: OpaquePointer) {
            sqlite3_reset(statementPointer)
            sqlite3_clear_bindings(statementPointer)
        }

        func bind(_ value: Double) throws {
            if sqlite3_bind_double(pointer, nextBindPosition, value) != SQLITE_OK {
                throw Error.bind(database.errorMessage)
            }
        }

        func bind(_ value: Int) throws {
            if sqlite3_bind_int(pointer, nextBindPosition, Int32(value)) != SQLITE_OK {
                throw Error.bind(database.errorMessage)
            }
        }

        func bind(_ value: String) throws {
            let strlen = Int32(value.characters.count)
            if sqlite3_bind_text(pointer, nextBindPosition, value, strlen, SQLITE_TRANSIENT) != SQLITE_OK {
                throw Error.bind(database.errorMessage)
            }
        }

        func bind(_ value: Bool) throws {
            try bind(value ? 1 : 0)
        }
    }
}

