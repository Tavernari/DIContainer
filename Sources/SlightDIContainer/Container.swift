//
//  Container.swift
//  
//
//  Created by Victor C Tavernari on 07/08/21.
//

import Foundation

public class Container: Injectable {

    private static func key(type: Any.Type) -> AnyHashable { ObjectIdentifier(type).hashValue }

    public static let shared = Container()

    public var dependencies: [AnyHashable: Any] = [:]
    private var keys: [Any] = []

    required public init() {}

    public func register<Value>(_ identifier: InjectIdentifier<Value>, _ resolve: (Resolvable) -> Value) {
        
        dependencies[identifier] = resolve( self )
    }

    public func remove<Value>(_ identifier: InjectIdentifier<Value>) {
        
        self.dependencies.removeValue(forKey: identifier)
    }
}

extension Container: Resolvable {

    public func resolve<Value>(_ identifier: InjectIdentifier<Value>) -> Value {

        guard let dependency = dependencies[identifier] as? Value else {

            fatalError("Could not find \(String(describing: identifier)) dependency as \(Value.self)")
        }

        return dependency
    }
}

@propertyWrapper public struct Injected<Value> {

    public init() {}
    
    public var wrappedValue: Value = Container.shared.resolve(.by(type: Value.self))
}

@propertyWrapper public struct WeakInjected<Value> {

    weak var service: Container?

    public init() {

        self.service = Container.shared
    }

    public var wrappedValue: Value? { service?.resolve(.by(type: Value.self)) }
}

@propertyWrapper public struct UnownedInjected<Value> {

    unowned var service: Container

    public init() {

        self.service = Container.shared
    }

    public var wrappedValue: Value { service.resolve(.by(type: Value.self)) }
}
