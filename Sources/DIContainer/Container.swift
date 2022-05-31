//
//  Container.swift
//  
//
//  Created by Victor C Tavernari on 07/08/21.
//

import Foundation

public class Container: Injectable {
    
    public static var standard = Container()

    public var dependencies: [AnyHashable: Any] = [:]

    required public init() {}
}

@propertyWrapper public struct Injected<Value> {
    
    public static func container() -> Injectable { Container.standard }

    private let identifier: InjectIdentifier<Value>
    private let container: Resolvable
    
    public init(_ identifier: InjectIdentifier<Value>? = nil, container: Resolvable? = nil) {
        self.identifier = identifier ?? .by(type: Value.self)
        self.container = container ?? Self.container()
    }
    
    public lazy var wrappedValue: Value = {
        do {
            
            return try container.resolve(identifier)
            
        } catch { fatalError( error.localizedDescription ) }
    }()
}

@propertyWrapper public struct InjectedSafe<Value> {
    
    public static func container() -> Injectable { Container.standard }

    private let identifier: InjectIdentifier<Value>
    private let container: Resolvable
    
    public init(_ identifier: InjectIdentifier<Value>? = nil, container: Resolvable? = nil) {
        self.identifier = identifier ?? .by(type: Value.self)
        self.container = container ?? Self.container()
    }
    
    public lazy var wrappedValue: Value? = try? container.resolve(identifier)
}
