
import Foundation

internal protocol URLEncoder {

    // RFC-3986
    static func urlEncode<T>(_ value: T) -> T

    // x-www-form-urlencoded
    static func urlFormEncode<T>(_ value: T) -> T
}

extension WebRequest : URLEncoder {

    // RFC-3986
    static func urlEncode<T>(_ value: T) -> T {
        switch (true) {
        case value is String:   return urlEncode(string: value as! String) as! T
        default:    return value
        }
    }

    static func urlEncode(string: String) -> String {
        let allowed1 = CharacterSet(charactersIn: "-._~/?@[]")
        let allowed2 = CharacterSet.alphanumerics
        return string.addingPercentEncoding(withAllowedCharacters: allowed1.union(allowed2)) ?? ""
    }

    // x-www-form-urlencoded
    static func urlFormEncode<T>(_ value: T) -> T {
        switch (true) {
        case value is String:   return urlFormEncode(string: value as! String) as! T
        default:    return value
        }
    }

    static func urlFormEncode(string: String) -> String {
        let allowed1 = CharacterSet(charactersIn: "*-._@[] ")
        let allowed2 = CharacterSet.alphanumerics
        return (string.addingPercentEncoding(withAllowedCharacters: allowed1.union(allowed2)) ?? "")
            .replacingOccurrences(of: " ", with: "+")
    }
}
