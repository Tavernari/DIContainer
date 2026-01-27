import Testing
@testable import DIContainer

@Suite("AutoDITests", .serialized)
struct AutoDITests {

    // MARK: - resolveAll Tests

    @Test func resolveAllWithSingleDependency() throws {
        let container = Container()
        container.register(type: String.self) { _ in "hello" }
        
        let result: String = try container.resolveAll()
        #expect(result == "hello")
    }

    @Test func resolveAllWithMultipleDependencies() throws {
        let container = Container()
        container.register(type: String.self) { _ in "hello" }
        container.register(type: Int.self) { _ in 42 }
        container.register(type: Double.self) { _ in 3.14 }
        
        let (str, num, dbl): (String, Int, Double) = try container.resolveAll()
        
        #expect(str == "hello")
        #expect(num == 42)
        #expect(dbl == 3.14)
    }
    
    @Test func resolveAllWithFiveDependencies() throws {
        let container = Container()
        container.register(type: String.self) { _ in "a" }
        container.register(type: Int.self) { _ in 1 }
        container.register(type: Double.self) { _ in 2.0 }
        container.register(type: Bool.self) { _ in true }
        container.register(type: Float.self) { _ in 3.0 }
        
        let (a, b, c, d, e): (String, Int, Double, Bool, Float) = try container.resolveAll()
        
        #expect(a == "a")
        #expect(b == 1)
        #expect(c == 2.0)
        #expect(d == true)
        #expect(e == 3.0)
    }

    @Test func resolveAllThrowsWhenMissing() {
        let container = Container()
        #expect(throws: (any Error).self) {
            let _: (String, Int) = try container.resolveAll()
        }
    }
    
    @Test func resolveAllThrowsWhenPartiallyMissing() {
        let container = Container()
        container.register(type: String.self) { _ in "exists" }
        
        #expect(throws: (any Error).self) {
            // Int is not registered
            let _: (String, Int) = try container.resolveAll()
        }
    }

    // MARK: - bootstrap Tests

    @Test func bootstrapIntegration() throws {
        let container = Container()
        container.bootstrap(MockAutoService.self)
        
        let service: MockServiceProtocol = try container.resolve(type: MockServiceProtocol.self)
        #expect(service.name == "MockService")
    }
    
    @Test func bootstrapMultipleTypes() throws {
        let container = Container()
        container.bootstrap(
            MockAutoService.self,
            MockAutoLogger.self
        )
        
        let service: MockServiceProtocol = try container.resolve(type: MockServiceProtocol.self)
        let logger: MockLoggerProtocol = try container.resolve(type: MockLoggerProtocol.self)
        
        #expect(service.name == "MockService")
        #expect(logger.prefix == "LOG:")
    }
    
    @Test func bootstrapWithDependencies() throws {
        let container = Container()
        // First register the dependency
        container.register(type: MockLoggerProtocol.self) { _ in MockLogger() }
        
        // Then bootstrap the service that depends on it
        container.bootstrap(MockServiceWithDependency.self)
        
        let service: MockServiceWithDeps = try container.resolve(type: MockServiceWithDeps.self)
        #expect(service.logMessage() == "LOG: Service started")
    }
    
    // MARK: - Circular Dependency with AutoDI
    
    @Test func autoRegisterWithCircularDependencyViaPropertyInjection() throws {
        // Must use Container.standard because @Injected uses it by default
        
        // Register both services
        Container.standard.bootstrap(
            CircularServiceA.self,
            CircularServiceB.self
        )
        
        // Resolve A - should work because B uses @Injected (lazy)
        let a: CircularProtocolA = try Container.standard.resolve(type: CircularProtocolA.self)
        #expect(a.name == "ServiceA")
        #expect(a.getBName() == "ServiceB")
    }
    
    // MARK: - Edge Cases
    
    @Test func resolveAllPreservesOrder() throws {
        let container = Container()
        container.register(type: String.self) { _ in "first" }
        container.register(type: Int.self) { _ in 2 }
        container.register(type: Bool.self) { _ in true }
        
        // Order must match the type declaration order
        let (s, i, b): (String, Int, Bool) = try container.resolveAll()
        #expect(s == "first")
        #expect(i == 2)
        #expect(b == true)
    }
    
    @Test func bootstrapIsIdempotent() throws {
        let container = Container()
        // Calling bootstrap multiple times should not cause issues
        container.bootstrap(MockAutoService.self)
        container.bootstrap(MockAutoService.self) // Second call
        
        let service: MockServiceProtocol = try container.resolve(type: MockServiceProtocol.self)
        #expect(service.name == "MockService")
    }
    
    @Test func resolveAllWithOptionalTypesFails() {
        let container = Container()
        // Registering a non-optional but trying to resolve as optional should fail
        // because we don't have Optional<String> registered
        #expect(throws: (any Error).self) {
            let _: String? = try container.resolveAll()
        }
    }
}

// MARK: - Test Helpers

protocol MockServiceProtocol {
    var name: String { get }
}

protocol MockLoggerProtocol {
    var prefix: String { get }
    func log(_ message: String) -> String
}

protocol MockServiceWithDeps {
    func logMessage() -> String
}

struct MockAutoService: MockServiceProtocol, AutoRegistrable {
    var name: String = "MockService"
    
    static func autoRegister(in container: Injectable) {
        container.register(type: MockServiceProtocol.self) { _ in
            MockAutoService()
        }
    }
}

struct MockLogger: MockLoggerProtocol {
    var prefix: String = "LOG:"
    func log(_ message: String) -> String { "\(prefix) \(message)" }
}

struct MockAutoLogger: MockLoggerProtocol, AutoRegistrable {
    var prefix: String = "LOG:"
    func log(_ message: String) -> String { "\(prefix) \(message)" }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: MockLoggerProtocol.self) { _ in
            MockAutoLogger()
        }
    }
}

struct MockServiceWithDependency: MockServiceWithDeps, AutoRegistrable {
    let logger: MockLoggerProtocol
    
    func logMessage() -> String {
        logger.log("Service started")
    }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: MockServiceWithDeps.self) { c in
            let logger: MockLoggerProtocol = try c.resolveAll()
            return MockServiceWithDependency(logger: logger)
        }
    }
}

// MARK: - Circular Dependency Helpers

protocol CircularProtocolA {
    var name: String { get }
    func getBName() -> String
}

protocol CircularProtocolB {
    var name: String { get }
}

class CircularServiceA: CircularProtocolA, AutoRegistrable {
    var name: String = "ServiceA"
    @Injected(.by(type: CircularProtocolB.self)) var b: CircularProtocolB
    
    func getBName() -> String { b.name }
    
    static func autoRegister(in container: Injectable) {
        container.register(type: CircularProtocolA.self) { _ in
            CircularServiceA()
        }
    }
}

class CircularServiceB: CircularProtocolB, AutoRegistrable {
    var name: String = "ServiceB"
    @Injected(.by(type: CircularProtocolA.self)) var a: CircularProtocolA
    
    static func autoRegister(in container: Injectable) {
        container.register(type: CircularProtocolB.self) { _ in
            CircularServiceB()
        }
    }
}
