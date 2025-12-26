import Testing
@testable import DIContainer

@Suite("SlightDIContainerTests", .serialized)
struct SlightDIContainerTests {
  
    init() {
        Container.standard.removeAllDependencies()
    }
    
    @Test func resolveUnavailableInjection() {
        let identifier = InjectIdentifier<String>.by(key: "key")
        #expect(throws: (any Error).self) {
            try Container.standard.resolve(identifier)
        }
    }
    
    @Test func registerContainerWithKey() {
        let value = "result"
        let key = "key"
        
        Container.standard.register(key: key) { _ in
            return value
        }
        
        let result: String = try! Container.standard.resolve(.by(key: key))
        #expect(result == value)
    }

    @Test func registerContainerWithKeyOnIdentifier() {
        let value = "result"
        let key = "key"
        
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
        
        var wrapperTest = WrapperTest()
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
        
        var wrapperTest = WrapperTest()
        #expect(wrapperTest.text == expectedResult)
        #expect(wrapperTest.textSafe == expectedResult)
    }
    
    @Test func wrapperInjectWithDefaultValueByStructType() {
        let expectedResult = "default_value"
        
        struct WrapperTest {
            @Injected(default: "default_value")
            var text: String
            
            @InjectedSafe
            var textSafe: String?
        }
        
        var wrapperTest = WrapperTest()
        #expect(wrapperTest.text == expectedResult)
        #expect(wrapperTest.textSafe == nil)
    }
}
