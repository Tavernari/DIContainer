import Testing
@testable import DIContainer

@Suite("DIContainerCoverageTests", .serialized)
struct DIContainerCoverageTests {
    
    init() {
        Container.standard.removeAllDependencies()
    }

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
        Container.standard.register(key: "key1") { _ in "value1" }
        #expect(Container.standard.dependencies.count == 1)
        
        // Test setter
        Container.standard.dependencies = [:]
        #expect(Container.standard.dependencies.isEmpty)
        
        let identifier = InjectIdentifier<String>.by(key: "key2")
        Container.standard.dependencies = [identifier: "value2"]
        #expect(Container.standard.dependencies.count == 1)
        let resolved = try? Container.standard.resolve(identifier)
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
