import XCTest
@testable import DIContainer

final class SlightDIContainerTests: XCTestCase {
  
    override func tearDown() {
        super.tearDown()
        
        Container.standard.removeAllDependencies()
    }
    
    func testResolveUnavailableInjection() throws {
        
        let identifier = InjectIdentifier<String>.by(key: "key")
        XCTAssertThrowsError(try Container.standard.resolve(identifier))
    }
    
    func testRegisterContainerWithKeyOnIdentifier() {
        
        let value = "result"
        let key = "key"
        
        Container.standard.register(.by(key: key)) { _ in
            return value
        }
        
        let result: String = try! Container.standard.resolve(.by(key: key))
        
        XCTAssertEqual(result, value)
    }
    
    func testRegisterContainerWithKey() {
        
        let value = "result"
        let key = "key"
        
        Container.standard.register(key: key) { _ in
            return value
        }
        
        let result: String = try! Container.standard.resolve(.by(key: key))
        
        XCTAssertEqual(result, value)
    }
    
    func testRegisterContainerWithTypeOnIdentifier() {
        
        struct ValueResult: Equatable { }
        
        let value = ValueResult()

        Container.standard.register(.by(type: ValueResult.self)) { _ in
            return value
        }
        
        let result = try! Container.standard.resolve(.by(type: ValueResult.self))
        
        XCTAssertEqual(result, value)
    }
    
    func testRegisterContainerWithType() {
        
        struct ValueResult: Equatable { }
        
        let value = ValueResult()

        Container.standard.register(type: ValueResult.self) { _ in
            return value
        }
        
        let result = try! Container.standard.resolve(.by(type: ValueResult.self))
        
        XCTAssertEqual(result, value)
    }
    
    func testRemoveFromContainerWithTypeOnIdentifier() {
        
        struct ValueResult: Equatable { }
        
        let value = ValueResult()

        Container.standard.register(.by(type: ValueResult.self)) { _ in
            return value
        }
        
        let identifier = InjectIdentifier.by(type: ValueResult.self)
        
        XCTAssertNotNil(Container.standard.dependencies[identifier])
        
        Container.standard.remove(.by(type: ValueResult.self))
        
        XCTAssertNil(Container.standard.dependencies[identifier])
    }
    
    func testRemoveFromContainerWithType() {
        
        struct ValueResult: Equatable { }
        
        let value = ValueResult()

        Container.standard.register(type: ValueResult.self) { _ in
            return value
        }
        
        let identifier = InjectIdentifier.by(type: ValueResult.self)
        
        XCTAssertNotNil(Container.standard.dependencies[identifier])
        
        Container.standard.remove(type: ValueResult.self)
        
        XCTAssertNil(Container.standard.dependencies[identifier])
    }
    
    func testWrapperInjectByKey() {
    
        let expectedResult = "result"

        
        Container.standard.register(.by(key: "textKey")) { _ in
            
            return expectedResult
        }
        
        class WrapperTest {
            
            @Injected(.by(key: "textKey"))
            var text: String
        }
        
        let wrapperTest = WrapperTest()
        
        XCTAssertEqual(wrapperTest.text, expectedResult)
    }
    
    func testWrapperInjectByType() {
    
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
        
        XCTAssertEqual(wrapperTest.text, expectedResult)
        XCTAssertEqual(wrapperTest.textSafe!, expectedResult)
    }
    
    func testWrapperInjectByStructType() {
    
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
        
        XCTAssertEqual(wrapperTest.text, expectedResult)
        XCTAssertEqual(wrapperTest.textSafe!, expectedResult)
    }
    
    func testWrapperInjectWithDefaultValueByStructType() {
    
        let expectedResult = "default_value"
        
        struct WrapperTest {
            
            @Injected(default: "default_value")
            var text: String
            
            @InjectedSafe
            var textSafe: String?
        }
        
        var wrapperTest = WrapperTest()
        
        XCTAssertEqual(wrapperTest.text, expectedResult)
        XCTAssertNil(wrapperTest.textSafe)
    }
}
