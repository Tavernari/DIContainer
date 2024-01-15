import Foundation

/// A structure used to uniquely identify dependencies for injection.
public struct InjectIdentifier<Value> {

    /// The type of the value to be injected.
    private(set) var type: Value.Type? = nil

    /// An optional key to further distinguish dependencies of the same type.
    private(set) var key: String? = nil

    /// Private initializer to create an `InjectIdentifier` instance.
    ///
    /// - Parameters:
    ///   - type: The type of the value to be injected.
    ///   - key: An optional key to further distinguish dependencies.
    private init(type: Value.Type? = nil, key: String? = nil) {
        self.type = type
        self.key = key
    }
}

/// Extension to make `InjectIdentifier` conform to `Hashable`.
extension InjectIdentifier: Hashable {

    /// Determines equality between two `InjectIdentifier` instances.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side `InjectIdentifier` instance.
    ///   - rhs: The right-hand side `InjectIdentifier` instance.
    /// - Returns: A Boolean value indicating whether the two instances are equal.
    public static func == (lhs: InjectIdentifier, rhs: InjectIdentifier) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
        if let type = self.type {
            hasher.combine(ObjectIdentifier(type))
        }
    }
}

/// Public extension to provide a convenient way to create an `InjectIdentifier`.
public extension InjectIdentifier {
    
    /// Creates an `InjectIdentifier` instance.
    ///
    /// - Parameters:
    ///   - type: The type of the value to be injected.
    ///   - key: An optional key to further distinguish dependencies.
    /// - Returns: An `InjectIdentifier` instance.
    static func by(type: Value.Type? = nil, key: String? = nil ) -> InjectIdentifier {
        return .init(type: type, key: key)
    }
}
