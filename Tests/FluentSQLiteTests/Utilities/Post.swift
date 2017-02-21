import Fluent

final class Post: Entity {
    let storage = Storage()

    /**
     Turn the convertible into a node
     
     - throws: if convertible can not create a Node
     - returns: a node if possible
     */
    var title: String
    var text: String
    
    init(id: Node?, title: String, text: String) {
        self.title = title
        self.text = text

        self.id = id
    }
    
    func makeNode(context:Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            "text": text
        ])
    }
    
    init(node: Node, in context: Context) throws {
        title = try node.extract("title")
        text = try node.extract("text")

        id = try node.extract(idKey)
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(for: Post.self)
            builder.string("title")
            builder.string("text")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
}
