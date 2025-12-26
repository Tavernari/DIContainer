import Foundation

/// A protocol defining the ability to resolve dependencies.
public protocol Resolvable {

    /// Resolves a dependency based on an identifier.
    ///
    /// - Parameter identifier: The identifier for the dependency to be resolved.
    /// - Throws: An error if the dependency cannot be resolved.
    /// - Returns: The resolved dependency of the given type `Value`.
    func resolve<Value>(_ identifier: InjectIdentifier<Value>) throws -> Value
}

/// An enumeration representing errors 
/// that can occur during the resolution of dependencies.
public enum ResolvableError: Error {
    
    /// Indicates that a dependency could not be found.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency that was not found.
    ///   - key: An optional key associated with the dependency.
    case dependencyNotFound(Any.Type?, String?)
}

/// Extension to make `ResolvableError` conform 
/// to `LocalizedError`, providing a localized description of the error.
extension ResolvableError: LocalizedError {
    
    /// A localized description of the error.
    public var errorDescription: String? {
        switch self {
        case let .dependencyNotFound(type, key):
            var message = "Could not find dependency for "
            if let type = type {
                message += "type: \(type) "
            } else if let key = key {
                message += "key: \(key)"
            }
            return message
        }
    }
}

/// A protocol representing an object that can inject dependencies.
///
/// Conforming types can register, remove, and resolve dependencies.
public protocol Injectable: Resolvable, AnyObject, Sendable {
    
    /// Initializes a new instance.
    init()



    /// Registers a dependency with an identifier.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the dependency.
    ///   - resolve: A closure that resolves the dependency.
    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) throws -> Value)

    /// Removes a dependency associated with an identifier.
    ///
    /// - Parameter identifier: The identifier for the dependency to be removed.
    func remove<Value>(_ identifier: InjectIdentifier<Value>)

    /// Removes all dependencies from the container.
    func removeAllDependencies()
}

/// Default implementations for the `Injectable` protocol.
public extension Injectable {
    
    /// Registers a dependency.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the dependency.
    ///   - resolve: A closure that resolves the dependency.
    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) throws -> Value) {
        fatalError("Implement this method in the conforming class")
    }
    
    /// Convenience method to register a dependency using type and optional key.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency.
    ///   - key: An optional key for the dependency.
    ///   - resolve: A closure that resolves the dependency.
    func register<Value>(type: Value.Type? = nil, key: String? = nil, _ resolve: (Resolvable) throws -> Value) {
        self.register(.by(type: type, key: key), resolve)
    }
    
    /// Removes a dependency associated with an identifier.
    ///
    /// - Parameter identifier: The identifier for the dependency to be removed.
    func remove<Value>(_ identifier: InjectIdentifier<Value>) {
        fatalError("Implement this method in the conforming class")
    }
    
    /// Convenience method to remove a dependency using type and optional key.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency.
    ///   - key: An optional key for the dependency.
    func remove<Value>(type: Value.Type? = nil, key: String? = nil) {
        let identifier = InjectIdentifier.by(type: type, key: key)
        self.remove(identifier)
    }
    
    /// Removes all dependencies from the container.
    func removeAllDependencies() {
        fatalError("Implement this method in the conforming class")
    }
    
    /// Resolves a dependency based on an identifier.
    ///
    /// - Parameter identifier: The identifier for the dependency to be resolved.
    /// - Throws: `ResolvableError.dependencyNotFound` if the dependency cannot be found.
    /// - Returns: The resolved dependency of the given type `Value`.
    func resolve<Value>(_ identifier: InjectIdentifier<Value>) throws -> Value {
        fatalError("Implement this method in the conforming class")
    }
    
    /// Convenience method to resolve a dependency using type and optional key.
    ///
    /// - Parameters:
    ///   - type: The type of the dependency.
    ///   - key: An optional key for the dependency.
    /// - Throws: `ResolvableError.dependencyNotFound` if the dependency cannot be found.
    /// - Returns: The resolved dependency of the given type `Value`.
    func resolve<Value>(type: Value.Type? = nil, key: String? = nil) throws -> Value {
        try self.resolve(.by(type: type, key: key))
    }
}
