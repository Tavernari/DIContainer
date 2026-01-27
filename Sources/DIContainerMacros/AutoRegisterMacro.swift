import SwiftSyntax
import SwiftSyntaxMacros

/// @AutoRegister - Automatically registers a type with the DI container.
///
/// Usage:
/// ```swift
/// @AutoRegister(MyProtocol.self)
/// struct MyService: MyProtocol {
///     init(dependency: DependencyProtocol) { ... }
/// }
/// ```
///
/// Generates:
/// ```swift
/// extension MyService: AutoRegistrable {
///     static func autoRegister(in container: Injectable) {
///         container.register(type: MyProtocol.self) { c in
///             let (dep,): (DependencyProtocol,) = try c.resolveAll()
///             return MyService(dependency: dep)
///         }
///     }
/// }
/// ```
public struct AutoRegisterMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Extract the protocol type from macro arguments
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = arguments.first else {
            throw MacroError.missingProtocolArgument
        }
        
        // Get the type name
        let typeName = type.trimmedDescription
        
        // Extract protocol name from argument (e.g., MyProtocol.self -> MyProtocol)
        let protocolArg = firstArg.expression.trimmedDescription
        let protocolName = protocolArg.replacingOccurrences(of: ".self", with: "")
        
        // Find the initializer and extract parameter types
        let initParams = extractInitializerParameters(from: declaration)
        
        // Generate the registration code
        let resolveAllTypes = initParams.map { $0.type }.joined(separator: ", ")
        let resolveAllTuple = initParams.count == 1 
            ? "(\(resolveAllTypes),)" 
            : "(\(resolveAllTypes))"
        
        let paramNames = initParams.map { $0.name }
        let resolveLetBinding = paramNames.count == 1
            ? "let (\(paramNames[0]),)"
            : "let (\(paramNames.joined(separator: ", ")))"
        
        let initCall = initParams.map { "\($0.label ?? $0.name): \($0.name)" }.joined(separator: ", ")
        
        let extensionDecl: DeclSyntax = """
        extension \(raw: typeName): AutoRegistrable {
            static func autoRegister(in container: Injectable) {
                container.register(type: \(raw: protocolName).self) { c in
                    \(raw: resolveLetBinding): \(raw: resolveAllTuple) = try c.resolveAll()
                    return \(raw: typeName)(\(raw: initCall))
                }
            }
        }
        """
        
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }
    
    private static func extractInitializerParameters(from declaration: some DeclGroupSyntax) -> [(name: String, label: String?, type: String)] {
        var params: [(name: String, label: String?, type: String)] = []
        
        for member in declaration.memberBlock.members {
            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else { continue }
            
            for param in initDecl.signature.parameterClause.parameters {
                let name = param.secondName?.text ?? param.firstName.text
                let label = param.firstName.text == "_" ? nil : param.firstName.text
                let type = param.type.trimmedDescription
                params.append((name: name, label: label, type: type))
            }
            break // Use the first initializer found
        }
        
        return params
    }
}

public enum MacroError: Error, CustomStringConvertible {
    case missingProtocolArgument
    case notAStructOrClass
    case noInitializerFound
    
    public var description: String {
        switch self {
        case .missingProtocolArgument:
            return "@AutoRegister requires a protocol type argument, e.g. @AutoRegister(MyProtocol.self)"
        case .notAStructOrClass:
            return "@AutoRegister can only be applied to structs or classes"
        case .noInitializerFound:
            return "No initializer found in the type"
        }
    }
}
