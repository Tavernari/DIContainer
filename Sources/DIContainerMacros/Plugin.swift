import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DIContainerMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutoRegisterMacro.self,
        AutoInjectedMacro.self,
        ResolveMacro.self,
        ResolvedMacro.self,
        ResolvedSafeMacro.self,
    ]
}
