import Fluent

class SQLiteDriver: Fluent.Driver {

	func fetchOne(table table: String, filters: [Filter]) -> [String: String]? {
		print("fetch one \(filters.count) filters on \(table)")

		return nil
	}

	func fetch(table table: String, filters: [Filter]) -> [[String: String]] {
		print("fetch \(filters.count) filters on \(table)")

		return []
	}

	func delete(table table: String, filters: [Filter]) {
		print("delete \(filters.count) filters on \(table)")

		//implement me
	}

	func update(table table: String, filters: [Filter], data: [String: String]) {
		print("update \(filters.count) filters \(data.count) data points on \(table)")

		//implement me
	}

	func insert(table table: String, items: [[String: String]]) {
		print("insert \(items.count) items into \(table)")

		//implement me
	}

	func upsert(table table: String, items: [[String: String]]) {
		//check if object exists
	}
 
	func exists(table table: String, filters: [Filter]) -> Bool {
		print("exists \(filters.count) filters on \(table)")

		return false
	}

	func count(table table: String, filters: [Filter]) -> Int {
		print("count \(filters.count) filters on \(table)")

		return 0
	}
}