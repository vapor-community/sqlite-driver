import PackageDescription

let package = Package(
    name: "FluentSQLite",
    dependencies: [ 
        .Package(url: "https://github.com/qutheory/csqlite.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/qutheory/fluent.git", majorVersion: 0, minor: 3)
    ]
)