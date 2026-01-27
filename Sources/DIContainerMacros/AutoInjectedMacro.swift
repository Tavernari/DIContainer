import SwiftSyntax
import SwiftSyntaxMacros

/// @AutoInjected - Property macro for automatic dependency injection.
///
/// Usage:
/// ```swift
/// class MyViewModel {
///     @AutoInjected var service: MyServiceProtocol
/// }
/// ```
///
/// Generates:
/// ```swift
/// private var _service: MyServiceProtocol?
/// var service: MyServiceProtocol {
///     get {
///         if let cached = _service { return cached }
///         let resolved = try! Container.standard.resolve(.by(type: MyServiceProtocol.self))
///         _service = resolved
///         return resolved
///     }
/// }
/// ```
public struct AutoInjectedMacro: AccessorMacro, PeerMacro {

    // MARK: - AccessorMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation else {
            return []
        }

        let propertyName = identifier.identifier.text
        let typeName = typeAnnotation.type.trimmedDescription
        let storageName = "_\(propertyName)"

        // Determine the resolve call based on arguments
        let resolveCall = buildResolveCall(from: node, typeName: typeName)

        let getter: AccessorDeclSyntax = """
        get {
            if let cached = \(raw: storageName) { return cached }
            let resolved = try! Container.standard.resolve(\(raw: resolveCall))
            \(raw: storageName) = resolved
            return resolved
        }
        """

        return [getter]
    }

    // MARK: - PeerMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation else {
            return []
        }

        let propertyName = identifier.identifier.text
        let typeName = typeAnnotation.type.trimmedDescription
        let storageName = "_\(propertyName)"

        let storageDecl: DeclSyntax = """
        private var \(raw: storageName): \(raw: typeName)?
        """

        return [storageDecl]
    }

    // MARK: - Helpers

    private static func buildResolveCall(from node: AttributeSyntax, typeName: String) -> String {
        // Check for identifier argument first: @AutoInjected(identifier: someIdentifier)
        if let identifierArg = extractIdentifierArgument(from: node) {
            return identifierArg
        }

        // Check for key argument: @AutoInjected(key: "myKey")
        if let keyArg = extractKeyArgument(from: node) {
            return ".by(type: \(typeName).self, key: \"\(keyArg)\")"
        }

        // Default: resolve by type only
        return ".by(type: \(typeName).self)"
    }

    private static func extractIdentifierArgument(from node: AttributeSyntax) -> String? {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }

        for arg in arguments {
            if arg.label?.text == "identifier" {
                // Return the expression as-is for the identifier
                return arg.expression.trimmedDescription
            }
        }
        return nil
    }

    private static func extractKeyArgument(from node: AttributeSyntax) -> String? {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }

        for arg in arguments {
            if arg.label?.text == "key",
               let stringLiteral = arg.expression.as(StringLiteralExprSyntax.self),
               let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                return segment.content.text
            }
        }
        return nil
    }
}
