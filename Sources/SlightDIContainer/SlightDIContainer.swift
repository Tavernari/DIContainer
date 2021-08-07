public protocol Resolvable {

    func resolve<Value>(_ identifier: InjectIdentifier<Value>) -> Value
}

public protocol Injectable: Resolvable {

    init()

    var dependencies: [AnyHashable: Any] { get set }

    func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) -> Value)

    func remove<Value>(_ identifier: InjectIdentifier<Value>)
}

public extension Injectable {

    init(with injectable: Injectable) {

        self.init()
        self.dependencies.merge(dict: injectable.dependencies)
    }
}

private extension Dictionary {
    
    mutating func merge(dict: [Key: Value]){
        
        for (k, v) in dict {
            
            updateValue(v, forKey: k)
        }
    }
}
