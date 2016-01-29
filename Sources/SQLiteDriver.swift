import Fluent

public class SQLiteDriver: Fluent.Driver {

	let database = SQLite()

	public func fetchOne(table table: String, filters: [Filter]) -> [String: String]? {
		let sql = SQL(operation: .SELECT, table: table)
		sql.filters = filters
		sql.limit = 1

		let rows = self.database.execute(sql.query)
		if rows.count > 0 {
			return rows[0].data
		}

		return nil
	}

	public func fetch(table table: String, filters: [Filter]) -> [[String: String]] {
		let sql = SQL(operation: .SELECT, table: table)
		sql.filters = filters

		var data: [[String: String]] = []

		for row in self.database.execute(sql.query) {
			data.append(row.data)
		}

		return data
	}

	public func delete(table table: String, filters: [Filter]) {
		let sql = SQL(operation: .DELETE, table: table)
		sql.filters = filters
		
		self.database.execute(sql.query)
	}

	public func update(table table: String, filters: [Filter], data: [String: String]) {
		let sql = SQL(operation: .UPDATE, table: table)
		sql.filters = filters
		sql.data = data

		self.database.execute(sql.query)
	}

	public func insert(table table: String, items: [[String: String]]) {
		for item in items {
			let sql = SQL(operation: .INSERT, table: table)
			sql.data = item

			self.database.execute(sql.query)
		}
	}

	public func upsert(table table: String, items: [[String: String]]) {
		//check if object exists
	}
 
	public func exists(table table: String, filters: [Filter]) -> Bool {
		print("exists \(filters.count) filters on \(table)")

		return false
	}

	public func count(table table: String, filters: [Filter]) -> Int {
		print("count \(filters.count) filters on \(table)")

		return 0
	}

	public init() {
		
	}
}