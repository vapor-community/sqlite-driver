import Fluent

class User: Model {
    var id: String?
    var name: String
    
    init(name: String, email: String) {
        self.name = name
    }
    
    func serialize() -> [String: Value] {
        return [
           "name": self.name,
        ]
    }
    
    class var entity: String {
        return "user"
    }
    
    required init(serialized: [String: Value]) {
        self.id = serialized["id"] as? String ?? ""
        self.name = serialized["name"] as? String ?? ""
    }
    
}