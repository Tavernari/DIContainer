/// `Container`: A singleton class to manage dependency injections.
///
/// This class provides a shared instance to manage dependencies across the application.
/// It allows for registering and retrieving dependencies via a dictionary.
public class Container: Injectable {
    
    /// The shared instance of `Container`.
    ///
    /// Use this static property to access the same instance of `Container` throughout the application.
    public static var standard = Container()

    /// A dictionary holding the dependencies.
    ///
    /// The dependencies are stored as key-value pairs where the key 
    /// is any hashable object and the value is the dependency.
    public var dependencies: [AnyHashable: Any] = [:]

    /// Creates a new instance of `Container`.
    ///
    /// This initializer is public and required as per the `Injectable` protocol.
    required public init() {}
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
