//
//  InjectIdentifier.swift
//  
//
//  Created by Victor C Tavernari on 07/08/21.
//

import Foundation

public struct InjectIdentifier<Value> {

    private(set) var type: Value.Type? = nil
    private(set) var key: String? = nil

    private init(type: Value.Type? = nil, key: String? = nil) {

        self.type = type
        self.key = key
    }
}

extension InjectIdentifier: Hashable {

    public static func == (lhs: InjectIdentifier, rhs: InjectIdentifier) -> Bool { lhs.hashValue == rhs.hashValue }

    public func hash(into hasher: inout Hasher) {

        hasher.combine(self.key)

        if let type = self.type {
            
            hasher.combine(ObjectIdentifier(type))
        }
    }
}

public extension InjectIdentifier {
    
    static func by(type: Value.Type? = nil, key: String? = nil ) -> InjectIdentifier {

        return .init(type: type, key: key)
    }
}
