// swift-tools-version: 5.9
import PackageDescription
import Foundation

// MARK: - Declarations
enum ProjectPaths {
    static let sources = "Sources"
}

// MARK: Local Modules
enum Local {
    case Core
    case UI
    case DI
    case Resources
    case Networking
    
    case Router(_ layer: FeatureImplLayer)
    case MainScreen(_ layer: FeatureLayer)
    case DetailScreen(_ layer: FeatureLayer)
    
}

// MARK: Remote Packages
enum RemotePackages: CaseIterable {
    // add new remote lib
     case Alamofire
    var spec: RemotePackageSpec {
        switch self {
         case .Alamofire:
             return .init(
                 "https://github.com/Alamofire/Alamofire.git",
                 packageName: "Alamofire",
                 version: "5.8.0"
             )
        }
    }
}

// MARK: Feature Layering System (Optional)
enum FeatureLayer: String {
    case Presentation, Domain, Data
}

enum FeatureImplLayer: String {
    case Impl, Api
    
}

// MARK: - Package Formation
let packageName = "DemoApp"
let package = buildPackage(
    name: packageName,
    defaultLocalization: "en",
    platforms: [.iOS(.v15)]
) {
    [
        Local.Router(.Impl).product(),
        Local.Router(.Api).product(),
        Local.Core.product()
    ]
} dependencies: {
    RemotePackages.allCases.map { $0.spec.buildDependency() }
} targets: {
    // Base modules
    Local.Networking.target(deps: [.module(.Core), .library(.Alamofire)])
    Local.UI.target(deps: [.module(.Core)])
    Local.DI.target(deps: [.module(.Core)])
    Local.Core.target()
    
    Local.Resources.target(resources: [
        .process("Resources.xcassets")
    ])
    
    featureTargets(module: { .Router($0) }, implementationExtra: [
        .module(.MainScreen(.Presentation)),
        .module(.DetailScreen(.Presentation))
    ])
    featureTargets(module: { .MainScreen($0)},
                   presentationExtra:  [ .module(Local.DI)] )
    
    featureTargets(module: { .DetailScreen($0)},
                   presentationExtra:  [ .module(Local.DI)] )
    
    
}












// MARK: - Feature configuration
func featureTargets(
    module: ( _ layer: FeatureLayer) -> Local,
    presentationExtra: [Target.Dependency] = [],
    domainExtra: [Target.Dependency] = [],
    dataExtra: [Target.Dependency] = []
) -> [Target] {

    let presentation = module(.Presentation)
    let domain = module(.Domain)
    let data = module(.Data)

    return [
        presentation.target(deps: [
            .module(domain.name),
            .module(.Core),
            .module(.UI),
            .module(.Resources)
        ] + presentationExtra),

        domain.target(deps: [
            .module(data.name),
            .module(.Core)
        ] + domainExtra),

        data.target(deps: [
            .module(.Core),
            .module(.Networking)
        ] + dataExtra)
    ]
}


func featureTargets(
    module: ( _ layer: FeatureImplLayer) -> Local,
    implementationExtra: [Target.Dependency] = [],
    apiExtra: [Target.Dependency] = []
) -> [Target] {

    let implementation = module(.Impl)
    let api = module(.Api)
    
    return [
        implementation.target(deps: [
            .module(api),
            .module(.Core)
        ] + implementationExtra),
        api.target(deps: apiExtra)
    ]
}


// MARK: - Helpers
extension Local {
    var name: String {
        let parsed = parsedDescription
        if let layer = parsed.layer {
            return "\(parsed.base)_\(layer)"
        }
        return parsed.base
    }
    
    private var path: String {
        let parsed = parsedDescription
        if let layer = parsed.layer {
            return "\(ProjectPaths.sources)/Features/\(parsed.base)/\(layer)"
        }
        return "\(ProjectPaths.sources)/\(parsed.base)"
    }
    
    private func module(_ resources: [Resource]?) -> TargetSpec {
       return TargetSpec(name: name, path: path, resources: resources)
    }
    private var module: TargetSpec { TargetSpec(name: name, path: path) }
    
    func target(deps: [Target.Dependency] = [], resources: [Resource]? = nil) -> Target {
        module(resources).target(deps: deps)
    }
    
    func product() -> Product {
        module.product()
    }
}

extension Target.Dependency {
    static func module(_ m: Local) -> Target.Dependency {
        .target(name: m.name)
    }
    
    static func module(_ name: String) -> Target.Dependency {
        .target(name: name)
    }
    
    static func library(_ lib: RemotePackages) -> Target.Dependency {
        .product(name: lib.spec.productName,
                 package: lib.spec.packageName)
    }
}

// MARK: - DSL Core
@resultBuilder
enum TargetsBuilder {
    static func buildBlock(_ parts: [Target]...) -> [Target] {
        parts.flatMap { $0 }
    }
    static func buildExpression(_ t: Target) -> [Target] { [t] }
    static func buildExpression(_ ts: [Target]) -> [Target] { ts }
}

@resultBuilder
enum ProductsBuilder {
    static func buildBlock(_ parts: [Product]...) -> [Product] {
        parts.flatMap { $0 }
    }
    static func buildExpression(_ p: Product) -> [Product] { [p] }
    static func buildExpression(_ ps: [Product]) -> [Product] { ps }
}

@resultBuilder
enum DependenciesBuilder {
    static func buildBlock(_ parts: [Package.Dependency]...) -> [Package.Dependency] {
        parts.flatMap { $0 }
    }
    static func buildExpression(_ d: Package.Dependency) -> [Package.Dependency] { [d] }
    static func buildExpression(_ ds: [Package.Dependency]) -> [Package.Dependency] { ds }
}

func buildPackage(
    name: String,
    defaultLocalization: LanguageTag? = nil,
    platforms: [SupportedPlatform] = [],
    @ProductsBuilder products: () -> [Product],
    @DependenciesBuilder dependencies: () -> [Package.Dependency],
    @TargetsBuilder targets: () -> [Target]
) -> Package {
    PackageSpec(
        name: name,
        defaultLocalization: defaultLocalization,
        platforms: platforms,
        products: products(),
        dependencies: dependencies(),
        targets: targets()
    ).build()
}

// MARK: - Specs
struct PackageSpec {
    var name: String
    var defaultLocalization: LanguageTag?
    var platforms: [SupportedPlatform] = []
    var products: [Product] = []
    var dependencies: [Package.Dependency] = []
    var targets: [Target] = []
    
    func build() -> Package {
        Package(
            name: name,
            defaultLocalization: defaultLocalization,
            platforms: platforms,
            products: products,
            dependencies: dependencies,
            targets: targets
        )
    }
}

struct RemotePackageSpec {
    let url: String
    let packageName: String
    let productName: String
    let version: Version
    
    init(_ url: String,
         packageName: String,
         productName: String? = nil,
         version: Version) {
        self.url = url
        self.packageName = packageName
        self.productName = productName ?? packageName
        self.version = version
    }
    
    func buildDependency() -> Package.Dependency {
        .package(url: url, from: version)
    }
}

struct TargetSpec {
    private let name: String
    private let path: String
    private let resources: [Resource]?
    init(name: String, path: String, resources: [Resource]? = nil) {
        self.name = name
        self.path = path
        self.resources = resources
    }
    
    func target(deps: [Target.Dependency] = []) -> Target {
        .target(
            name: name,
            dependencies: deps,
            path: path,
            resources: resources
        )
    }
    
    func testTarget(deps: [Target.Dependency] = []) -> Target {
        .testTarget(
            name: name,
            dependencies: deps,
            path: path
        )
    }
    
    func product() -> Product {
        .library(name: name, targets: [name])
    }
}

// MARK: - Helper to automatically generate the feature path and name for import
extension Local {
    private var parsedDescription: (base: String, layer: String?) {
        let description = String(describing: self)

        guard
            let start = description.firstIndex(of: "("),
            let end = description.firstIndex(of: ")")
        else {
            return (description, nil)
        }

        let base = String(description[..<start])
        var layer = String(description[description.index(after: start)..<end])

        // remove type prefix like "Main.FeatureLayer."
        if let last = layer.split(separator: ".").last {
            layer = String(last).capitalizedFirst
        }

        return (base, layer)
    }
}

extension String {
    var capitalizedFirst: String {
        prefix(1).uppercased() + dropFirst()
    }
}
