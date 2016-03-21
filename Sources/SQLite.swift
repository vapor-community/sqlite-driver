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
    private var statementPointer: UnsafeMutablePointer<COpaquePointer> = nil
	var database: COpaquePointer = nil
    
	init() throws {
        let code = sqlite3_open_v2("main.sqlite", &self.database, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
		if code != SQLITE_OK {
            print(code)
            sqlite3_close(self.database)
            throw SQLiteError.ConnectionException
		}
	}

	func close() {
		sqlite3_close(self.database)
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
    
    func execute(statement: String, bindHandler: (() -> ())) throws -> [Result.Row] {
        self.statementPointer = UnsafeMutablePointer<COpaquePointer>.alloc(1)
        if sqlite3_prepare_v2(self.database, statement, -1, self.statementPointer, nil) != SQLITE_OK {
            print("preparing failed")
            return []
        }
        
        bindHandler()
        let result = Result()
        while sqlite3_step(self.statementPointer.memory) == SQLITE_ROW {
            
            let row = Result.Row()
            let columnCount = sqlite3_column_count(self.statementPointer.memory)
            
            for i in 0..<columnCount {
                let row = Result.Row()
                guard let value = String.fromCString(UnsafePointer(sqlite3_column_text(self.statementPointer.memory, i))) else {
                    continue
                }
                
                guard let columnName = String.fromCString(sqlite3_column_name(self.statementPointer.memory, i)) else {
                    continue
                }
                
                row.data[columnName] = value
            }
            
            result.rows.append(row)
        }
        
        let status = sqlite3_finalize(self.statementPointer.memory)
        if status != SQLITE_OK {
            print(errorMessage())
            print("Preparing statement failed! status \(status)")
            return []
        }
        
        return result.rows
    }
    
    func execute(statement: String) throws -> [Result.Row] {
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

		}, resultPointer, nil)

		if code != SQLITE_OK {
            print(errorMessage())
            throw SQLiteError.SQLException
		}

		return result.rows
	}
    
    func errorMessage() -> String {
        let error = String.fromCString(sqlite3_errmsg(self.database)) ?? ""
        return error
    }
    
    func reset(statementPointer: COpaquePointer) {
        sqlite3_reset(statementPointer)
        sqlite3_clear_bindings(statementPointer)
    }
    
    func bind(value: String, position: Int) {
        let status = sqlite3_bind_text(self.statementPointer.memory, Int32(position), value, -1, SQLITE_TRANSIENT)
        if status != SQLITE_OK {
            print(errorMessage())
        }
    }
    
    func bind(value: Int32, position: Int) {
        if sqlite3_bind_int(self.statementPointer.memory, Int32(position), value) != SQLITE_OK {
            print(errorMessage())
        }
    }
    
    func bind(value: Int64, position: Int) {
        if sqlite3_bind_int64(self.statementPointer.memory, Int32(position), value) != SQLITE_OK {
            print(errorMessage())
        }
    }
    
    func bind(value: Double, position: Int) {
        if sqlite3_bind_double(self.statementPointer.memory, Int32(position), value) != SQLITE_OK {
            print(errorMessage())
        }
    }
    
    func bind(value: Bool, position: Int) {
        if sqlite3_bind_int(self.statementPointer.memory, Int32(position), value ? 1 : 0) != SQLITE_OK {
            print(errorMessage())
        }
    }
    
	func test() {
		try! self.execute("CREATE TABLE user (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL);")
		try! self.execute("INSERT INTO user (id, name) VALUES (NULL, 'Tanner');")
		try! self.execute("INSERT INTO user (id, name) VALUES (NULL, 'Jill');")
	}

}