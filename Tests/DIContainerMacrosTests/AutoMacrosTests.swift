import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import DIContainerMacros

@Suite("AutoRegisterMacroTests")
struct AutoRegisterMacroTests {
    
    let testMacros: [String: Macro.Type] = [
        "AutoRegister": AutoRegisterMacro.self,
    ]
    
    @Test func autoRegisterGeneratesExtension() {
        assertMacroExpansion(
            """
            @AutoRegister(MyProtocol.self)
            struct MyService: MyProtocol {
                init(dependency: DependencyProtocol) {
                    self.dependency = dependency
                }
            }
            """,
            expandedSource: """
            struct MyService: MyProtocol {
                init(dependency: DependencyProtocol) {
                    self.dependency = dependency
                }
            }
            
            extension MyService: AutoRegistrable {
                static func autoRegister(in container: Injectable) {
                    container.register(type: MyProtocol.self) { c in
                        let (dependency,): (DependencyProtocol,) = try c.resolveAll()
                        return MyService(dependency: dependency)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoRegisterWithMultipleDependencies() {
        assertMacroExpansion(
            """
            @AutoRegister(ServiceProtocol.self)
            struct Service: ServiceProtocol {
                init(repo: RepoProtocol, logger: LoggerProtocol) {
                    self.repo = repo
                    self.logger = logger
                }
            }
            """,
            expandedSource: """
            struct Service: ServiceProtocol {
                init(repo: RepoProtocol, logger: LoggerProtocol) {
                    self.repo = repo
                    self.logger = logger
                }
            }
            
            extension Service: AutoRegistrable {
                static func autoRegister(in container: Injectable) {
                    container.register(type: ServiceProtocol.self) { c in
                        let (repo, logger): (RepoProtocol, LoggerProtocol) = try c.resolveAll()
                        return Service(repo: repo, logger: logger)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoRegisterWithNoParameters() {
        assertMacroExpansion(
            """
            @AutoRegister(SimpleProtocol.self)
            struct SimpleService: SimpleProtocol {
                init() {}
            }
            """,
            expandedSource: """
            struct SimpleService: SimpleProtocol {
                init() {}
            }
            
            extension SimpleService: AutoRegistrable {
                static func autoRegister(in container: Injectable) {
                    container.register(type: SimpleProtocol.self) { c in
                        let (): () = try c.resolveAll()
                        return SimpleService()
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoRegisterWithFiveDependencies() {
        assertMacroExpansion(
            """
            @AutoRegister(ComplexProtocol.self)
            struct ComplexService: ComplexProtocol {
                init(a: AProtocol, b: BProtocol, c: CProtocol, d: DProtocol, e: EProtocol) {
                    // ...
                }
            }
            """,
            expandedSource: """
            struct ComplexService: ComplexProtocol {
                init(a: AProtocol, b: BProtocol, c: CProtocol, d: DProtocol, e: EProtocol) {
                    // ...
                }
            }
            
            extension ComplexService: AutoRegistrable {
                static func autoRegister(in container: Injectable) {
                    container.register(type: ComplexProtocol.self) { c in
                        let (a, b, c, d, e): (AProtocol, BProtocol, CProtocol, DProtocol, EProtocol) = try c.resolveAll()
                        return ComplexService(a: a, b: b, c: c, d: d, e: e)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoRegisterWithUnderscoreLabel() {
        assertMacroExpansion(
            """
            @AutoRegister(ServiceProtocol.self)
            struct Service: ServiceProtocol {
                init(_ unlabeled: DependencyProtocol) {
                    self.dep = unlabeled
                }
            }
            """,
            expandedSource: """
            struct Service: ServiceProtocol {
                init(_ unlabeled: DependencyProtocol) {
                    self.dep = unlabeled
                }
            }
            
            extension Service: AutoRegistrable {
                static func autoRegister(in container: Injectable) {
                    container.register(type: ServiceProtocol.self) { c in
                        let (unlabeled,): (DependencyProtocol,) = try c.resolveAll()
                        return Service(unlabeled)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoRegisterOnClass() {
        assertMacroExpansion(
            """
            @AutoRegister(ViewModelProtocol.self)
            class ViewModel: ViewModelProtocol {
                init(service: ServiceProtocol) {
                    self.service = service
                }
            }
            """,
            expandedSource: """
            class ViewModel: ViewModelProtocol {
                init(service: ServiceProtocol) {
                    self.service = service
                }
            }
            
            extension ViewModel: AutoRegistrable {
                static func autoRegister(in container: Injectable) {
                    container.register(type: ViewModelProtocol.self) { c in
                        let (service,): (ServiceProtocol,) = try c.resolveAll()
                        return ViewModel(service: service)
                    }
                }
            }
            """,
            macros: testMacros
        )
    }
}

@Suite("AutoInjectedMacroTests")
struct AutoInjectedMacroTests {
    
    let testMacros: [String: Macro.Type] = [
        "AutoInjected": AutoInjectedMacro.self,
    ]
    
    @Test func autoInjectedGeneratesAccessorAndStorage() {
        assertMacroExpansion(
            """
            class ViewModel {
                @AutoInjected var service: MyServiceProtocol
            }
            """,
            expandedSource: """
            class ViewModel {
                var service: MyServiceProtocol {
                    get {
                        if let cached = _service { return cached }
                        let resolved = try! Container.standard.resolve(.by(type: MyServiceProtocol.self))
                        _service = resolved
                        return resolved
                    }
                }
            
                private var _service: MyServiceProtocol?
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoInjectedWithKey() {
        assertMacroExpansion(
            """
            class ViewModel {
                @AutoInjected(key: "premium") var service: ServiceProtocol
            }
            """,
            expandedSource: """
            class ViewModel {
                var service: ServiceProtocol {
                    get {
                        if let cached = _service { return cached }
                        let resolved = try! Container.standard.resolve(.by(type: ServiceProtocol.self, key: "premium"))
                        _service = resolved
                        return resolved
                    }
                }
            
                private var _service: ServiceProtocol?
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoInjectedInStruct() {
        assertMacroExpansion(
            """
            struct MyView {
                @AutoInjected var viewModel: ViewModelProtocol
            }
            """,
            expandedSource: """
            struct MyView {
                var viewModel: ViewModelProtocol {
                    get {
                        if let cached = _viewModel { return cached }
                        let resolved = try! Container.standard.resolve(.by(type: ViewModelProtocol.self))
                        _viewModel = resolved
                        return resolved
                    }
                }
            
                private var _viewModel: ViewModelProtocol?
            }
            """,
            macros: testMacros
        )
    }
    
    @Test func autoInjectedMultipleProperties() {
        assertMacroExpansion(
            """
            class ViewModel {
                @AutoInjected var serviceA: ServiceAProtocol
                @AutoInjected var serviceB: ServiceBProtocol
            }
            """,
            expandedSource: """
            class ViewModel {
                var serviceA: ServiceAProtocol {
                    get {
                        if let cached = _serviceA { return cached }
                        let resolved = try! Container.standard.resolve(.by(type: ServiceAProtocol.self))
                        _serviceA = resolved
                        return resolved
                    }
                }
            
                private var _serviceA: ServiceAProtocol?
                var serviceB: ServiceBProtocol {
                    get {
                        if let cached = _serviceB { return cached }
                        let resolved = try! Container.standard.resolve(.by(type: ServiceBProtocol.self))
                        _serviceB = resolved
                        return resolved
                    }
                }
            
                private var _serviceB: ServiceBProtocol?
            }
            """,
            macros: testMacros
        )
    }
}

// MARK: - Resolve Expression Macro Tests

@Suite("ResolveMacroTests")
struct ResolveMacroTests {
    
    let testMacros: [String: Macro.Type] = [
        "resolve": ResolveMacro.self,
        "resolved": ResolvedMacro.self,
        "resolvedSafe": ResolvedSafeMacro.self,
    ]
    
    @Test func resolveBasic() {
        assertMacroExpansion(
            """
            let service: MyProtocol = try #resolve
            """,
            expandedSource: """
            let service: MyProtocol = try Container.standard.resolve()
            """,
            macros: testMacros
        )
    }
    
    @Test func resolveWithKey() {
        assertMacroExpansion(
            """
            let service: MyProtocol = try #resolve(key: "premium")
            """,
            expandedSource: """
            let service: MyProtocol = try Container.standard.resolve(key: "premium")
            """,
            macros: testMacros
        )
    }
    
    @Test func resolvedBasic() {
        assertMacroExpansion(
            """
            let service: MyProtocol = #resolved
            """,
            expandedSource: """
            let service: MyProtocol = try! Container.standard.resolve()
            """,
            macros: testMacros
        )
    }
    
    @Test func resolvedWithKey() {
        assertMacroExpansion(
            """
            let service: MyProtocol = #resolved(key: "premium")
            """,
            expandedSource: """
            let service: MyProtocol = try! Container.standard.resolve(key: "premium")
            """,
            macros: testMacros
        )
    }
    
    @Test func resolvedSafeBasic() {
        assertMacroExpansion(
            """
            let service: MyProtocol? = #resolvedSafe
            """,
            expandedSource: """
            let service: MyProtocol? = Container.standard.resolveSafe()
            """,
            macros: testMacros
        )
    }
    
    @Test func resolvedSafeWithKey() {
        assertMacroExpansion(
            """
            let service: MyProtocol? = #resolvedSafe(key: "premium")
            """,
            expandedSource: """
            let service: MyProtocol? = Container.standard.resolveSafe(key: "premium")
            """,
            macros: testMacros
        )
    }
    
    @Test func resolveInContainer() {
        assertMacroExpansion(
            """
            let service: MyProtocol = try #resolve(in: myContainer)
            """,
            expandedSource: """
            let service: MyProtocol = try myContainer.resolve()
            """,
            macros: testMacros
        )
    }
}
