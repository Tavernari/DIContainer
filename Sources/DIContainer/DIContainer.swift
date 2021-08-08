import Foundation

public protocol Resolvable {

    func resolve<Value>(_ identifier: InjectIdentifier<Value>) throws -> Value
}

public enum ResolvableError: Error {
    
    case dependencyNotFound(Any.Type?, String?)
}

extension ResolvableError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .dependencyNotFound(type, key):
            
            var message = "Could not find dependency for "
            
            if let type = type {
                message += "type: \(type) "
            } else if let key = key {
                message += "key: \(key)"
            }
            
            return message
        }
    }
}

public protocol Injectable: Resolvable, AnyObject {
    
    init()

    var dependencies: [AnyHashable: Any] { get set }

    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) throws -> Value)

    func remove<Value>(_ identifier: InjectIdentifier<Value>)
}

public extension Injectable {

    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) throws -> Value) {
        
        do {
            
            self.dependencies[identifier] = try resolve( self )
        
        } catch {
            
            assertionFailure(error.localizedDescription)
        }
    }

    func remove<Value>(_ identifier: InjectIdentifier<Value>) {
        
        self.dependencies.removeValue(forKey: identifier)
    }
    
    func removeAllDependencies() {
        
        self.dependencies.removeAll()
    }
    
    func resolve<Value>(_ identifier: InjectIdentifier<Value>) throws -> Value {

        guard let dependency = dependencies[identifier] as? Value else {
            
            throw ResolvableError.dependencyNotFound(identifier.type, identifier.key)
        }

        return dependency
    }
}
