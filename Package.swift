import PackageDescription

let package = Package(
    name: "FluentSQLite",
    dependencies: [ 
   		.Package(url: "https://github.com/tannernelson/csqlite.git", majorVersion: 0),
        //.Package(url: "https://github.com/kylef/Spectre.git", majorVersion: 0) //testing
        .Package(url: "https://github.com/tannernelson/fluent.git", majorVersion: 0)
    ]
)