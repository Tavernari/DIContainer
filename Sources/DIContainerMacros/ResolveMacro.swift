import SwiftSyntax
import SwiftSyntaxMacros

/// #resolve - Freestanding expression macro for dependency resolution.
///
/// Usage:
/// ```swift
/// let service: MyProtocol = try #resolve
/// let keyed: MyProtocol = try #resolve(key: "premium")
/// ```
///
/// Expands to:
/// ```swift
/// Container.standard.resolve(.by(type: MyProtocol.self))
/// Container.standard.resolve(.by(type: MyProtocol.self, key: "premium"))
/// ```
public struct ResolveMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let keyArg = extractArgument(from: node, label: "key")
        let idArg = extractArgumentExpression(from: node, label: "identifier")
        let containerArg = extractArgumentExpression(from: node, label: "in")
        
        let container = containerArg ?? "Container.standard"
        
        if let idExpr = idArg {
            return "\(container).resolve(\(idExpr))"
        } else if let key = keyArg {
            return "\(container).resolve(key: \"\(raw: key)\")"
        } else {
            return "\(container).resolve()"
        }
    }
}

public struct ResolvedMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let keyArg = extractArgument(from: node, label: "key")
        let idArg = extractArgumentExpression(from: node, label: "identifier")
        let containerArg = extractArgumentExpression(from: node, label: "in")
        
        let container = containerArg ?? "Container.standard"
        
        if let idExpr = idArg {
            return "try! \(container).resolve(\(idExpr))"
        } else if let key = keyArg {
            return "try! \(container).resolve(key: \"\(raw: key)\")"
        } else {
            return "try! \(container).resolve()"
        }
    }
}

public struct ResolvedSafeMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let keyArg = extractArgument(from: node, label: "key")
        let idArg = extractArgumentExpression(from: node, label: "identifier")
        let containerArg = extractArgumentExpression(from: node, label: "in")
        
        let container = containerArg ?? "Container.standard"
        
        if let idExpr = idArg {
            return "\(container).resolveSafe(\(idExpr))"
        } else if let key = keyArg {
            return "\(container).resolveSafe(key: \"\(raw: key)\")"
        } else {
            return "\(container).resolveSafe()"
        }
    }
}

// Helper functions (not public)
fileprivate func extractArgument(from node: some FreestandingMacroExpansionSyntax, label: String) -> String? {
    let arguments = node.arguments
    for arg in arguments {
        if arg.label?.text == label,
           let stringLiteral = arg.expression.as(StringLiteralExprSyntax.self),
           let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
            return segment.content.text
        }
    }
    return nil
}

fileprivate func extractArgumentExpression(from node: some FreestandingMacroExpansionSyntax, label: String) -> ExprSyntax? {
    let arguments = node.arguments
    for arg in arguments {
        if arg.label?.text == label {
            return arg.expression
        }
    }
    return nil
}
