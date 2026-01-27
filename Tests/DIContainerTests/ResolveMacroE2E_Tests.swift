import Testing
import DIContainer

/// E2E tests for #resolve, #resolved, #resolvedSafe expression macros.
/// Uses explicit local containers via `in:` parameter to avoid parallel execution conflicts.
@Suite("ResolveMacroE2E_Tests", .serialized)
struct ResolveMacroE2E_Tests {
    
    // MARK: - Test Types
    
    struct Service_Resolved { let name: String }
    struct Service_ResolvedKey { let name: String }
    struct Service_Safe { let name: String }
    struct Service_SafeKey { let name: String }
    struct Service_Resolve { let name: String }
    struct Service_ResolveKey { let name: String }
    struct Service_Identifier { let name: String }
    struct Service_ResolvedIdentifier { let name: String }
    
    struct Config_Workflow { func getEnvironment() -> String { "production" } }
    struct Logger_Workflow { 
        let config: Config_Workflow
        func log(_ msg: String) -> String { "[\(config.getEnvironment())] \(msg)" }
    }
    
    struct MissingService { }
    
    // MARK: - Tests
    
    @Test func resolvedMacroE2E() {
        let container = Container()
        container.register(type: Service_Resolved.self) { _ in
            Service_Resolved(name: "ResolvedService")
        }
        
        let service: Service_Resolved = #resolved(in: container)
        #expect(service.name == "ResolvedService")
    }
    
    @Test func resolvedWithKeyMacroE2E() {
        let container = Container()
        Container.standard.register(type: Service_ResolvedKey.self, key: "vip_macro") { _ in
            Service_ResolvedKey(name: "VIPService")
        }
        
        // Note: Mix of explicit container and implicit (if registered on standard) 
        // But here we want isolation. So we register on local container.
        container.register(type: Service_ResolvedKey.self, key: "vip_macro") { _ in
             Service_ResolvedKey(name: "VIPService")
        }
        
        let service: Service_ResolvedKey = #resolved(key: "vip_macro", in: container)
        #expect(service.name == "VIPService")
    }
    
    @Test func resolvedSafeMacroE2E() throws {
        let container = Container()
        container.register(type: Service_Safe.self) { _ in
            Service_Safe(name: "SafeService")
        }
        
        let service: Service_Safe? = #resolvedSafe(in: container)
        #expect(service?.name == "SafeService")
    }
    
    @Test func resolvedSafeNotFoundMacroE2E() {
        let container = Container()
        let service: MissingService? = #resolvedSafe(in: container)
        #expect(service == nil)
    }
    
    @Test func resolvedSafeWithKeyMacroE2E() throws {
        let container = Container()
        container.register(type: Service_SafeKey.self, key: "optional_macro") { _ in
            Service_SafeKey(name: "OptionalService")
        }
        
        let service: Service_SafeKey? = #resolvedSafe(key: "optional_macro", in: container)
        #expect(service?.name == "OptionalService")
        
        let missing: Service_SafeKey? = #resolvedSafe(key: "nonexistent", in: container)
        #expect(missing == nil)
    }
    
    @Test func resolveMacroE2E() throws {
        let container = Container()
        container.register(type: Service_Resolve.self) { _ in
            Service_Resolve(name: "ThrowingService")
        }
        
        let service: Service_Resolve = try #resolve(in: container)
        #expect(service.name == "ThrowingService")
    }
    
    @Test func resolveWithKeyMacroE2E() throws {
        let container = Container()
        container.register(type: Service_ResolveKey.self, key: "premium_macro") { _ in
            Service_ResolveKey(name: "PremiumService")
        }
        
        let service: Service_ResolveKey = try #resolve(key: "premium_macro", in: container)
        #expect(service.name == "PremiumService")
    }
    
    @Test func completeWorkflowWithMacrosE2E() throws {
        let container = Container()
        container.register(type: Config_Workflow.self) { _ in
            Config_Workflow()
        }
        container.register(type: Logger_Workflow.self) { c in
            let (config,): (Config_Workflow,) = try c.resolveAll()
            return Logger_Workflow(config: config)
        }
        
        let config: Config_Workflow = try #resolve(in: container)
        #expect(config.getEnvironment() == "production")
        
        let logger: Logger_Workflow = #resolved(in: container)
        #expect(logger.log("test") == "[production] test")
    }
    
    // MARK: - Identifier Tests
    
    @Test func resolveWithIdentifierMacroE2E() throws {
        let container = Container()
        container.register(type: Service_Identifier.self) { _ in
            Service_Identifier(name: "ExplicitIdentifier")
        }
        
        let service: Service_Identifier = try #resolve(identifier: .by(type: Service_Identifier.self), in: container)
        #expect(service.name == "ExplicitIdentifier")
    }
    
    @Test func resolvedWithIdentifierMacroE2E() {
        let container = Container()
        container.register(type: Service_ResolvedIdentifier.self) { _ in
            Service_ResolvedIdentifier(name: "ExplicitResolved")
        }
        
        let service: Service_ResolvedIdentifier = #resolved(identifier: .by(type: Service_ResolvedIdentifier.self), in: container)
        #expect(service.name == "ExplicitResolved")
    }
}
