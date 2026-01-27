import Testing
import Foundation
@testable import DIContainer

@Suite("SlightDIContainerTests", .serialized)
struct SlightDIContainerTests {
    
    @Test func resolveUnavailableInjection() {
        // Use a UUID-based key that's guaranteed to not be registered
        let identifier = InjectIdentifier<String>.by(key: "nonexistent_\(UUID().uuidString)")
        #expect(throws: (any Error).self) {
            try Container.standard.resolve(identifier)
        }
    }
    
    @Test func registerContainerWithKey() {
        let value = "result"
        let key = "slight_key_\(UUID().uuidString)"
        
        Container.standard.register(key: key) { _ in
            return value
        }
        
        let result: String = try! Container.standard.resolve(.by(key: key))
        #expect(result == value)
    }

    @Test func registerContainerWithKeyOnIdentifier() {
        let value = "result"
        let key = "slight_id_\(UUID().uuidString)"
        
        Container.standard.register(.by(key: key)) { _ in
            return value
        }
        
        let result: String = try! Container.standard.resolve(.by(key: key))
        #expect(result == value)
    }
    
    @Test func registerContainerWithTypeOnIdentifier() {
        struct ValueResult: Equatable { }
        let value = ValueResult()

        Container.standard.register(.by(type: ValueResult.self)) { _ in
            return value
        }
        
        let result = try! Container.standard.resolve(.by(type: ValueResult.self))
        #expect(result == value)
    }
    
    @Test func registerContainerWithType() {
        struct ValueResult: Equatable { }
        let value = ValueResult()

        Container.standard.register(type: ValueResult.self) { _ in
            return value
        }
        
        let result = try! Container.standard.resolve(.by(type: ValueResult.self))
        #expect(result == value)
    }
    
    @Test func removeFromContainerWithTypeOnIdentifier() {
        struct ValueResult: Equatable { }
        let value = ValueResult()

        Container.standard.register(.by(type: ValueResult.self)) { _ in
            return value
        }
        
        let identifier = InjectIdentifier.by(type: ValueResult.self)
        #expect(Container.standard.dependencies[identifier] != nil)
        
        Container.standard.remove(.by(type: ValueResult.self))
        #expect(Container.standard.dependencies[identifier] == nil)
    }
    
    @Test func removeFromContainerWithType() {
        struct ValueResult: Equatable { }
        let value = ValueResult()

        Container.standard.register(type: ValueResult.self) { _ in
            return value
        }
        
        let identifier = InjectIdentifier.by(type: ValueResult.self)
        #expect(Container.standard.dependencies[identifier] != nil)
        
        Container.standard.remove(type: ValueResult.self)
        #expect(Container.standard.dependencies[identifier] == nil)
    }
    
    @Test func wrapperInjectByKey() {
        let expectedResult = "result"
        Container.standard.register(.by(key: "textKey")) { _ in
            return expectedResult
        }
        
        class WrapperTest {
            @Injected(.by(key: "textKey"))
            var text: String
        }
        
        let wrapperTest = WrapperTest()
        #expect(wrapperTest.text == expectedResult)
    }
    
    @Test func wrapperInjectByType() {
        let expectedResult = "result"
        Container.standard.register(.by(type: String.self)) { _ in
            return expectedResult
        }
        
        class WrapperTest {
            @Injected
            var text: String
            
            @InjectedSafe
            var textSafe: String?
        }
        
        let wrapperTest = WrapperTest()
        #expect(wrapperTest.text == expectedResult)
        #expect(wrapperTest.textSafe == expectedResult)
    }
    
    @Test func wrapperInjectByStructType() {
        let expectedResult = "result"
        Container.standard.register(.by(type: String.self)) { _ in
            return expectedResult
        }
        
        struct WrapperTest {
            @Injected
            var text: String
            
            @InjectedSafe
            var textSafe: String?
        }
        
        let wrapperTest = WrapperTest()
        #expect(wrapperTest.text == expectedResult)
        #expect(wrapperTest.textSafe == expectedResult)
    }
    
    @Test func wrapperInjectWithDefaultValueByStructType() {
        // Use a unique type that won't be registered by other tests
        struct UniqueDefaultTestType: Equatable {
            let value: String
        }
        let defaultValue = UniqueDefaultTestType(value: "default_value")
        
        struct WrapperTest {
            @Injected(default: UniqueDefaultTestType(value: "default_value"))
            var text: UniqueDefaultTestType
            
            @InjectedSafe
            var textSafe: UniqueDefaultTestType?
        }
        
        let wrapperTest = WrapperTest()
        #expect(wrapperTest.text == defaultValue)
        #expect(wrapperTest.textSafe == nil)
    }
}
