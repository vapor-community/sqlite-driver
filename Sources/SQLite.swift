#if os(Linux)
	import CSQLiteLinux
#else
	import CSQLiteMac
#endif

let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)

public enum SQLiteError: ErrorType {
    case ConnectionException, SQLException, IndexOutOfBoundsException
}

class SQLite {
	var database: COpaquePointer = nil

	init() throws {
        let code = sqlite3_open_v2("Database/main.sqlite", &self.database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil);
		if code != SQLITE_OK {
            print(code)
            sqlite3_close(self.database);
            throw SQLiteError.ConnectionException
		}
	}

	func close() {
		sqlite3_close(self.database);
	}

	class Result {
		class Row {
			var data: [String: String]

			init() {
				self.data = [:]
			}
		}

		var rows: [Row]

		init() {
			self.rows = []
		}
	}

    func execute(statement: String, values: [Any]? = nil) throws -> [Result.Row] {
        if let values = values where !values.isEmpty {
            try bind(values)
        }

		let resultPointer = UnsafeMutablePointer<Result>.alloc(1)

		var result = Result()
		resultPointer.initializeFrom(&result, count: 1)

        
		let code = sqlite3_exec(self.database, statement, { resultVoidPointer, columnCount, values, columns in
			let resultPointer = UnsafeMutablePointer<Result>(resultVoidPointer)
			let result = resultPointer.memory

			let row = Result.Row()
			for i in 0 ..< Int(columnCount) {
				guard let value = String.fromCString(values[i]) else {
					print("No value")
					continue
				}

				guard let column = String.fromCString(columns[i]) else {
					print("No column")
					continue
				}

				row.data[column] = value
			}

			result.rows.append(row)
			return 0
		}, resultPointer, nil);

		if code != SQLITE_OK {
			let error = String.fromCString(sqlite3_errmsg(self.database))
			print("Query error \(code) for statement '\(statement)' error \(error)")
            throw SQLiteError.SQLException
		}

		return result.rows
	}
    
    func bind(values: [Any]) throws {
        if values.isEmpty {
            return
        }
        
//        sqlite3_reset(self.database)
//        sqlite3_clear_bindings(self.database)
        
        guard values.count == Int(sqlite3_bind_parameter_count(self.database)) else {
            let paramCount = sqlite3_bind_parameter_count(self.database)
            print("\(paramCount) values expected, \(values.count) passed")
            throw SQLiteError.IndexOutOfBoundsException
        }
        
        for i in 1...values.count {
            bind(values[i - 1], index: i)
        }
    }
    
    func bind(value: Any, index: Int) {
//        if value == nil {
//            sqlite3_bind_null(self.database, Int32(index))
//        } else
        if value is Double {
            sqlite3_bind_double(self.database, Int32(index), value as! Double)
        } else if value is Int64 {
            sqlite3_bind_int64(self.database, Int32(index), value as! Int64)
        } else if value is String {
            sqlite3_bind_text(self.database, Int32(index), value as! String, -1, SQLITE_TRANSIENT)
        } else if value is Int {
            self.bind(value, index: index)
        } else if value is Bool {
            self.bind(value, index: index)
        } else {
            fatalError("tried to bind unexpected value \(value)")
        }
    }
    
	func test() {
		try! self.execute("CREATE TABLE user (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL);")
		try! self.execute("INSERT INTO user (id, name) VALUES (NULL, 'Tanner');")
		try! self.execute("INSERT INTO user (id, name) VALUES (NULL, 'Jill');")
	}

}