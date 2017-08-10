//
//  APIGraphObjects.swift
//  WICS
//
//  Created by Rosalia Dupont on 8/9/17.
//  Copyright © 2017 Make School. All rights reserved.
//

/*import Foundation
import FBSDKLoginKit
import FacebookCore
import FBSDKCoreKit


public protocol OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    var openGraphPropertyValue: Any { get }
}

internal struct OpenGraphPropertyValueConverter {
    internal static func valueFrom(openGraphObjectValue value: Any) -> OpenGraphPropertyValue? {
        switch value {
        case let value as String: return value
        case let value as NSNumber: return value
        case let value as NSArray: return value.flatMap { valueFrom(openGraphObjectValue: $0 as AnyObject) }
        case let value as URL: return value
        //case let value as FBSDKSharePhoto: return Photo(sdkPhoto: value)
        //case let value as FBSDKShareOpenGraphObject: return OpenGraphObject(sdkGraphObject: value)
        default:
            print("Recieved unknown OpenGraph value \(value)")
            return nil
        }
    }
}

extension NSNumber: OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    public var openGraphPropertyValue: Any {
        return self
    }
}

extension String: OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    public var openGraphPropertyValue: Any {
        return self
    }
}

extension Array: OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    public var openGraphPropertyValue: Any {
        return self
            .flatMap { $0 as? OpenGraphPropertyValue }
            .map { $0.openGraphPropertyValue }
    }
}

extension URL: OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    public var openGraphPropertyValue: Any {
        return self
    }
}

/*extension Photo: OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    public var openGraphPropertyValue: Any {
        return sdkPhotoRepresentation
    }
}*/

extension OpenGraphObject: OpenGraphPropertyValue {
    /// The bridged OpenGraph raw value.
    public var openGraphPropertyValue: Any {
        return sdkGraphObjectRepresentation
    }
}


public struct OpenGraphPropertyName {
    /// The namespace of this open graph property
    public var namespace: String
    
    /// The name of this open graph property
    public var name: String
    
    /**
     Attempt to parse an `OpenGraphPropertyName` from a raw OpenGraph formatted property name.
     
     - parameter string: The string to create from.
     */
    public init?(_ string: String) {
        let components = string.characters.split(separator: ":")
        guard components.count >= 2 else {
            return nil
        }
        
        self.namespace = String(components[0])
        
        let subcharacters = components[1 ... components.count]
        self.name = subcharacters.reduce("", { $0 + ":" + String($1) })
    }
    
    /**
     Create an `OpenGraphPropertyName` with a specific namespace and name.
     
     - parameter namespace: The namespace to use.
     - parameter name:      The name to use.
     */
    public init(namespace: String, name: String) {
        self.namespace = namespace
        self.name = name
    }
}

extension OpenGraphPropertyName: RawRepresentable {
    public typealias RawValue = String
    
    /// The raw OpenGraph formatted property name.
    public var rawValue: String {
        return namespace.isEmpty
            ? name
            : namespace + ":" + name
    }
    
    /**
     Attempt to parse an `OpenGraphPropertyName` from a raw OpenGraph formatted proeprty name.
     
     - parameter rawValue: The string to create from.
     */
    public init(rawValue: String) {
        self.init(stringLiteral: rawValue)
    }
}

extension OpenGraphPropertyName: ExpressibleByStringLiteral {
    /**
     Create an `OpenGraphPropertyName` from a string literal.
     
     - parameter value: The string literal to create from.
     */
    public init(stringLiteral value: String) {
        guard let propertyName = OpenGraphPropertyName(value) else {
            print("Warning: Attempting to create OpenGraphPropertyName for string \"\(value)\", which has no namespace!")
            
            self.namespace = ""
            self.name = value
            return
        }
        
        self.namespace = propertyName.namespace
        self.name = propertyName.name
    }
    
    /**
     Create an `OpenGraphPropertyName` from a unicode scalar literal.
     
     - parameter value: The scalar literal to create from.
     */
    public init(unicodeScalarLiteral value: UnicodeScalarType) {
        self.init(stringLiteral: value)
    }
    
    /**
     Create an `OpenGraphPropertyName` from an grapheme cluster literal.
     
     - parameter value: The grapheme cluster to create from.
     */
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
        self.init(stringLiteral: value)
    }
}

extension OpenGraphPropertyName: Hashable {
    /// Calculates the hash value of this `OpenGraphPropertyName`.
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    /**
     Compares two `OpenGraphPropertyName`s for equality.
     
     - parameter lhs: The first property name to compare.
     - parameter rhs: The second property name to compare.
     
     - returns: Whether or not these names are equal.
     */
    public static func == (lhs: OpenGraphPropertyName, rhs: OpenGraphPropertyName) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}


public struct OpenGraphObject {
    fileprivate var properties: [OpenGraphPropertyName : OpenGraphPropertyValue]
    
    /**
     Create a new `OpenGraphObject`.
     */
    public init() {
        properties = [:]
    }
}

extension OpenGraphObject: OpenGraphPropertyContaining {
    /// Get the property names contained in this container.
    public var propertyNames: Set<OpenGraphPropertyName> {
        return Set(properties.keys)
    }
    
    public subscript(key: OpenGraphPropertyName) -> OpenGraphPropertyValue? {
        get {
            return properties[key]
        } set {
            properties[key] = newValue
        }
    }
}

extension OpenGraphObject: ExpressibleByDictionaryLiteral {
    /**
     Convenience method to build a new object from a dictinary literal.
     
     - parameter elements: The elements of the dictionary literal to initialize from.
     
     - example:
     ```
     let object: OpenGraphObject = [
     "og:type": "foo",
     "og:title": "bar",
     ....
     ]
     ```
     */
    public init(dictionaryLiteral elements: (OpenGraphPropertyName, OpenGraphPropertyValue)...) {
        properties = [:]
        for (key, value) in elements {
            properties[key] = value
        }
    }
}

extension OpenGraphObject {
    internal var sdkGraphObjectRepresentation: FBSDKShareOpenGraphObject {
        let sdkObject = FBSDKShareOpenGraphObject()
        sdkObject.parseProperties(properties.keyValueMap { key, value in
            (key.rawValue, value.openGraphPropertyValue)
        })
        return sdkObject
    }
    
    internal init(sdkGraphObject: FBSDKShareOpenGraphObject) {
        var properties = [OpenGraphPropertyName : OpenGraphPropertyValue]()
        sdkGraphObject.enumerateKeysAndObjects { (key: String?, value: Any?, stop) in
            guard let key = key.map(OpenGraphPropertyName.init(rawValue:)),
                let value = value.map(OpenGraphPropertyValueConverter.valueFrom) else {
                    return
            }
            properties[key] = value
        }
        self.properties = properties
    }
}

extension OpenGraphObject: Equatable {
    /**
     Compare two `OpenGraphObject`s for equality.
     
     - parameter lhs: The first `OpenGraphObject` to compare.
     - parameter rhs: The second `OpenGraphObject` to compare.
     
     - returns: Whether or not the objects are equal.
     */
    public static func == (lhs: OpenGraphObject, rhs: OpenGraphObject) -> Bool {
        return false
    }
}*/
