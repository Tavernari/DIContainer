import Foundation

/// `Container`: A singleton class to manage dependency injections.
///
/// This class provides a shared instance to manage dependencies across the application.
/// It allows for registering and retrieving dependencies via a dictionary.
public final class Container: Injectable, @unchecked Sendable {
    
    /// The shared instance of `Container`.
    ///
    /// Use this static property to access the same instance of `Container` throughout the application.
    public static let standard = Container()

    private enum DependencyEntry {
        case instance(Any)
        case factory((Resolvable) throws -> Any)
    }

    private let lock = NSRecursiveLock()
    private var _dependencies: [AnyHashable: DependencyEntry] = [:]

    /// A dictionary holding the dependencies.
    ///
    /// The dependencies are stored as key-value pairs where the key 
    /// is any hashable object and the value is the dependency.
    public var dependencies: [AnyHashable: Any] {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            var dependencies: [AnyHashable: Any] = [:]
            for (key, value) in _dependencies {
                switch value {
                case .instance(let instance):
                    dependencies[key] = instance
                case .factory(let factory):
                    // Factories are exposed as closures to maintain compatibility with 
                    // existence checks (dependencies[id] != nil).
                    dependencies[key] = factory
                }
            }
            return dependencies
        }
        set {
            lock.lock()
            defer { lock.unlock() }
             
            var newDependencies: [AnyHashable: DependencyEntry] = [:]
            for (key, value) in newValue {
                newDependencies[key] = .instance(value)
            }
            _dependencies = newDependencies
        }
    }

    /// Creates a new instance of `Container`.
    ///
    /// This initializer is public and required as per the `Injectable` protocol.
    required public init() {}

    public func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: @escaping (Resolvable) throws -> Value) {
        lock.lock()
        defer { lock.unlock() }
        _dependencies[identifier] = .factory(resolve)
    }

    public func remove<Value>(_ identifier: InjectIdentifier<Value>) {
        lock.lock()
        defer { lock.unlock() }
        _dependencies.removeValue(forKey: identifier)
    }

    public func removeAllDependencies() {
        lock.lock()
        defer { lock.unlock() }
        _dependencies.removeAll()
    }

    public func resolve<Value>(_ identifier: InjectIdentifier<Value>) throws -> Value {
        lock.lock()
        defer { lock.unlock() }
        
        guard let entry = _dependencies[identifier] else {
            throw ResolvableError.dependencyNotFound(identifier.type, identifier.key)
        }
        
        switch entry {
        case .instance(let instance):
            guard let castedInstance = instance as? Value else {
                throw ResolvableError.dependencyNotFound(identifier.type, identifier.key)
            }
            return castedInstance
        case .factory(let factory):
            let instance = try factory(self)
            guard let castedInstance = instance as? Value else {
                throw ResolvableError.dependencyNotFound(identifier.type, identifier.key)
            }
            // Cache the resolved instance to ensure singleton behavior if desired,
            // or just to avoid re-running factory if it was meant to be one-time.
            // Based on original implementation being a singleton container that resolved once at registration,
            // we should cache the result to maintain "Singleton" scope behavior for the life of the container.
            _dependencies[identifier] = .instance(castedInstance)
            return castedInstance
        }
    }
    
    /// Resolves multiple dependencies at once using Variadic Generics.
    ///
    /// Usage:
    /// ```swift
    /// let (repo, service): (RepoProtocol, ServiceProtocol) = try container.resolveAll()
    /// ```
    public func resolveAll<each T>() throws -> (repeat each T) {
        (repeat try self.resolve(.by(type: (each T).self)))
    }
    
    // MARK: - Type-Inferred Resolution (for #resolve macros)
    
    /// Resolves a dependency using type inference from the context.
    ///
    /// Usage:
    /// ```swift
    /// let service: MyProtocol = try container.resolve()
    /// ```
    public func resolve<T>() throws -> T {
        try self.resolve(.by(type: T.self))
    }
    
    /// Resolves a dependency by key using type inference from the context.
    ///
    /// Usage:
    /// ```swift
    /// let service: MyProtocol = try container.resolve(key: "premium")
    /// ```
    public func resolve<T>(key: String) throws -> T {
        try self.resolve(.by(type: T.self, key: key))
    }
    
    /// Safely resolves a dependency using type inference (returns nil if not found).
    public func resolveSafe<T>() -> T? {
        try? self.resolve(.by(type: T.self))
    }
    
    /// Safely resolves a dependency by key using type inference.
    public func resolveSafe<T>(key: String) -> T? {
        try? self.resolve(.by(type: T.self, key: key))
    }
    
    /// Safely resolves a dependency by identifier.
    public func resolveSafe<T>(_ identifier: InjectIdentifier<T>) -> T? {
        try? self.resolve(identifier)
    }
}

/// A property wrapper for injecting dependencies.
///
/// This struct wraps a property and injects a dependency into it. 
/// If the dependency cannot be resolved and no default value is provided,
/// it will crash the application.
@propertyWrapper public struct Injected<Value> {
    
    /// Error types related to dependency injection.
    enum Error: Swift.Error {
        case couldNotResolveAndDefaultIsNil
    }
    
    /// Returns the standard container used for resolving dependencies.
    public static func container() -> Injectable { Container.standard }

    private let identifier: InjectIdentifier<Value>
    private let container: Resolvable
    private let `default`: Value?

    /// Creates a new `Injected` instance.
    ///
    /// - Parameters:
    ///   - identifier: The identifier used to resolve the dependency. Defaults to the type of `Value`.
    ///   - container: The container used for resolving the dependency. Defaults to `Container.standard`.
    ///   - default: An optional default value to use if the dependency cannot be resolved.
    public init(_ identifier: InjectIdentifier<Value>? = nil, container: Resolvable? = nil, `default`: Value? = nil) {
        self.identifier = identifier ?? .by(type: Value.self)
        self.container = container ?? Self.container()
        self.default = `default`
    }
    
    /// The resolved value of the dependency.
    ///
    /// This property lazily resolves the dependency. 
    /// If the dependency cannot be resolved, it will use the provided default value.
    /// If both fail, the application will crash.
    public lazy var wrappedValue: Value = {
        if let value = try? container.resolve(identifier) {
            return value
        }
        
        if let `default` {
            return `default`
        }
        
        fatalError("Could not resolve with \(identifier) and default is nil")
    }()
}

/// A property wrapper for safely injecting dependencies.
///
/// This struct wraps a property and injects an optional dependency into it. 
/// If the dependency cannot be resolved, the property will be nil.
@propertyWrapper public struct InjectedSafe<Value> {
    
    /// Returns the standard container used for resolving dependencies.
    public static func container() -> Injectable { Container.standard }

    private let identifier: InjectIdentifier<Value>
    private let container: Resolvable

    /// Creates a new `InjectedSafe` instance.
    ///
    /// - Parameters:
    ///   - identifier: The identifier used to resolve the dependency. Defaults to the type of `Value`.
    ///   - container: The container used for resolving the dependency. Defaults to `Container.standard`.
    public init(_ identifier: InjectIdentifier<Value>? = nil, container: Resolvable? = nil) {
        self.identifier = identifier ?? .by(type: Value.self)
        self.container = container ?? Self.container()
    }
    
    /// The optionally resolved value of the dependency.
    ///
    /// This property lazily tries to resolve the dependency. 
    /// If the dependency cannot be resolved, the property will be nil.
    public lazy var wrappedValue: Value? = try? container.resolve(identifier)
}
