public protocol Resolvable {

    func resolve<Value>(_ identifier: InjectIdentifier<Value>) throws -> Value
}

enum ResolvableError: Error {
    
    case dependencyNotFound(Any.Type?, String?)
}

public protocol Injectable: Resolvable, AnyObject {
    
    init()

    var dependencies: [AnyHashable: Any] { get set }

    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) -> Value)

    func remove<Value>(_ identifier: InjectIdentifier<Value>)
}

public extension Injectable {

    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) -> Value) {
        
        self.dependencies[identifier] = resolve( self )
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
