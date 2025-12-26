import XCTest
@testable import DIContainer

final class DIContainerCoverageTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        Container.standard.removeAllDependencies()
    }

    func testResolvableErrorDescription() {
        let typeError = ResolvableError.dependencyNotFound(String.self, nil)
        XCTAssertEqual(typeError.localizedDescription, "Could not find dependency for type: String ")
        
        let keyError = ResolvableError.dependencyNotFound(nil, "someKey")
        XCTAssertEqual(keyError.localizedDescription, "Could not find dependency for key: someKey")
        
        let bothError = ResolvableError.dependencyNotFound(String.self, "someKey")
        XCTAssertEqual(bothError.localizedDescription, "Could not find dependency for type: String ") // Logic prefers type if present
        
        let noneError = ResolvableError.dependencyNotFound(nil, nil)
        XCTAssertEqual(noneError.localizedDescription, "Could not find dependency for ")
    }
    
    func testContainerDependenciesSetter() {
        Container.standard.register(key: "key1") { _ in "value1" }
        XCTAssertEqual(Container.standard.dependencies.count, 1)
        
        // Test setter
        Container.standard.dependencies = [:]
        XCTAssertTrue(Container.standard.dependencies.isEmpty)
        
        let identifier = InjectIdentifier<String>.by(key: "key2")
        Container.standard.dependencies = [identifier: "value2"]
        XCTAssertEqual(Container.standard.dependencies.count, 1)
        XCTAssertEqual(try? Container.standard.resolve(identifier), "value2")
    }
    
    func testResolveConvenienceMethod() throws {
        Container.standard.register(type: String.self) { _ in "test" }
        
        // Use the convenience resolve(type:key:)
        let result: String = try Container.standard.resolve(type: String.self)
        XCTAssertEqual(result, "test")
        
        // Test with key
        Container.standard.register(type: Int.self, key: "number") { _ in 42 }
        let number: Int = try Container.standard.resolve(type: Int.self, key: "number")
        XCTAssertEqual(number, 42)
    }
    
    func testSafeResolveFailure() {
        let result: String? = try? Container.standard.resolve(type: String.self, key: "missing")
        XCTAssertNil(result)
    }
}
