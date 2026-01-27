import Testing
import Foundation
@testable import DIContainer

@Suite("DIContainerCoverageTests", .serialized)
struct DIContainerCoverageTests {

    @Test func resolvableErrorDescription() {
        let typeError = ResolvableError.dependencyNotFound(String.self, nil)
        #expect(typeError.localizedDescription == "Could not find dependency for type: String ")
        
        let keyError = ResolvableError.dependencyNotFound(nil, "someKey")
        #expect(keyError.localizedDescription == "Could not find dependency for key: someKey")
        
        let bothError = ResolvableError.dependencyNotFound(String.self, "someKey")
        #expect(bothError.localizedDescription == "Could not find dependency for type: String ") // Logic prefers type if present
        
        let noneError = ResolvableError.dependencyNotFound(nil, nil)
        #expect(noneError.localizedDescription == "Could not find dependency for ")
    }
    
    @Test func containerDependenciesSetter() {
        let uniqueKey1 = "coverage_key1_\(UUID().uuidString)"
        let uniqueKey2 = "coverage_key2_\(UUID().uuidString)"
        
        let container = Container() // Use local container for this test
        container.register(key: uniqueKey1) { _ in "value1" }
        #expect(container.dependencies.count == 1)
        
        // Test setter
        container.dependencies = [:]
        #expect(container.dependencies.isEmpty)
        
        let identifier = InjectIdentifier<String>.by(key: uniqueKey2)
        container.dependencies = [identifier: "value2"]
        #expect(container.dependencies.count == 1)
        let resolved = try? container.resolve(identifier)
        #expect(resolved == "value2")
    }
    
    @Test func resolveConvenienceMethod() throws {
        Container.standard.register(type: String.self) { _ in "test" }
        
        // Use the convenience resolve(type:key:)
        let result: String = try Container.standard.resolve(type: String.self)
        #expect(result == "test")
        
        // Test with key
        Container.standard.register(type: Int.self, key: "number") { _ in 42 }
        let number: Int = try Container.standard.resolve(type: Int.self, key: "number")
        #expect(number == 42)
    }
    
    @Test func safeResolveFailure() {
        let result: String? = try? Container.standard.resolve(type: String.self, key: "missing")
        #expect(result == nil)
    }
}
