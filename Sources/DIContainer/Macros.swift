// MARK: - Auto DI Macros

/// Automatically registers a type with the DI container.
///
/// Usage:
/// ```swift
/// @AutoRegister(MyProtocol.self)
/// struct MyService: MyProtocol {
///     init(dependency: SomeDependency) { ... }
/// }
/// ```
///
/// The macro generates an `AutoRegistrable` conformance with an `autoRegister(in:)` method
/// that automatically resolves all init dependencies using `resolveAll()`.
@attached(extension, conformances: AutoRegistrable, names: named(autoRegister))
public macro AutoRegister(_ protocolType: Any.Type) = #externalMacro(
    module: "DIContainerMacros",
    type: "AutoRegisterMacro"
)

/// Automatically registers a type with a specific key.
///
/// Usage:
/// ```swift
/// @AutoRegister(key: "premium", as: MyProtocol.self)
/// struct PremiumService: MyProtocol { ... }
/// ```
@attached(extension, conformances: AutoRegistrable, names: named(autoRegister))
public macro AutoRegister<T>(key: String, as protocolType: T.Type) = #externalMacro(
    module: "DIContainerMacros",
    type: "AutoRegisterMacro"
)

/// Zero-overhead property injection via compile-time code generation.
///
/// Usage:
/// ```swift
/// class MyViewModel {
///     @AutoInjected var service: MyServiceProtocol
/// }
/// ```
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro AutoInjected() = #externalMacro(
    module: "DIContainerMacros",
    type: "AutoInjectedMacro"
)

/// Zero-overhead property injection with a specific key.
///
/// Usage:
/// ```swift
/// @AutoInjected(key: "premium") var premium: MyServiceProtocol
/// ```
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro AutoInjected(key: String) = #externalMacro(
    module: "DIContainerMacros",
    type: "AutoInjectedMacro"
)

/// Zero-overhead property injection with an explicit identifier.
///
/// Usage:
/// ```swift
/// @AutoInjected(identifier: InjectIdentifier<MyProtocol>.by(key: "premium")) var premium: MyProtocol
/// ```
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro AutoInjected<T>(identifier: InjectIdentifier<T>) = #externalMacro(
    module: "DIContainerMacros",
    type: "AutoInjectedMacro"
)

// MARK: - Freestanding Expression Macros

/// Resolves a dependency from the container (throwing).
///
/// Usage:
/// ```swift
/// let service: MyProtocol = try #resolve
/// let keyed: MyProtocol = try #resolve(key: "premium")
/// ```
@freestanding(expression)
public macro resolve<T>() -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolveMacro"
)

/// Resolves a dependency with a specific key (throwing).
@freestanding(expression)
public macro resolve<T>(key: String) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolveMacro"
)

/// Resolves a dependency, crashing if not found.
///
/// Usage:
/// ```swift
/// let service: MyProtocol = #resolved
/// ```
@freestanding(expression)
public macro resolved<T>() -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedMacro"
)

/// Resolves a dependency with key, crashing if not found.
@freestanding(expression)
public macro resolved<T>(key: String) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedMacro"
)

/// Safely resolves a dependency, returning nil if not found.
///
/// Usage:
/// ```swift
/// let service: MyProtocol? = #resolvedSafe
/// ```
@freestanding(expression)
public macro resolvedSafe<T>() -> T? = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedSafeMacro"
)

/// Safely resolves a dependency with key, returning nil if not found.
@freestanding(expression)
public macro resolvedSafe<T>(key: String) -> T? = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedSafeMacro"
)

/// Resolves a dependency using an explicit identifier (throwing).
@freestanding(expression)
public macro resolve<T>(identifier: InjectIdentifier<T>) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolveMacro"
)

/// Resolves a dependency using an explicit identifier, crashing if not found.
@freestanding(expression)
public macro resolved<T>(identifier: InjectIdentifier<T>) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedMacro"
)

/// Safely resolves a dependency using an explicit identifier, returning nil if not found.
@freestanding(expression)
public macro resolvedSafe<T>(identifier: InjectIdentifier<T>) -> T? = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedSafeMacro"
)

// MARK: - Overloads with Container Injection (in: Resolvable)

@freestanding(expression)
public macro resolve<T>(in container: Resolvable) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolveMacro"
)

@freestanding(expression)
public macro resolve<T>(key: String, in container: Resolvable) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolveMacro"
)

@freestanding(expression)
public macro resolve<T>(identifier: InjectIdentifier<T>, in container: Resolvable) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolveMacro"
)

@freestanding(expression)
public macro resolved<T>(in container: Resolvable) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedMacro"
)

@freestanding(expression)
public macro resolved<T>(key: String, in container: Resolvable) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedMacro"
)

@freestanding(expression)
public macro resolved<T>(identifier: InjectIdentifier<T>, in container: Resolvable) -> T = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedMacro"
)

@freestanding(expression)
public macro resolvedSafe<T>(in container: Resolvable) -> T? = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedSafeMacro"
)

@freestanding(expression)
public macro resolvedSafe<T>(key: String, in container: Resolvable) -> T? = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedSafeMacro"
)

@freestanding(expression)
public macro resolvedSafe<T>(identifier: InjectIdentifier<T>, in container: Resolvable) -> T? = #externalMacro(
    module: "DIContainerMacros",
    type: "ResolvedSafeMacro"
)

