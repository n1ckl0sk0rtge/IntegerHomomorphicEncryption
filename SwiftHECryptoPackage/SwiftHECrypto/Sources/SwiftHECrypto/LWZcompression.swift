//
//  LWZcompression.swift
//  IntegerHomomorphicEncryption
//
//  Created by Nicklas Körtge on 01.04.21.

import Foundation

class LZW {
    static let shared = LZW()
    
    var dictionary : [String : Int]
    var invers_dictionary : [Int : String]
    
    private init() {
        dictionary = [String : Int]()
        invers_dictionary = [Int : String]()
        
        for i in 0..<256 {
            let char = String(UnicodeScalar(UInt8(i)))
            dictionary[char] = i
            invers_dictionary[i] = char
        }
    }
    
    func compress(_ str: String) -> [Int] {
        
        var dic = dictionary
        var placeholder = String()
        var code = [Int]()
        
        for char in str {
            let observedString = placeholder + String(char)
            
            if let _ = dic[observedString] {
                placeholder = observedString
            } else {
                code.append(dic[placeholder]!)
                dic[observedString] = dic.count + 1
                placeholder = String(char)
            }
        }
        
        if placeholder != String() {
            code.append(dic[placeholder]!)
        }
        
        return code
    }
    
    func decompress(_ code: [Int]) -> String? {
        
        var dic = invers_dictionary
        var placeholder = String(UnicodeScalar(UInt8(code[0])))
        var str = placeholder
        
        for i in 1..<code.count {
            var char : String
            if let c = dic[code[i]] {
                char = c
            } else if i == dic.count {
                char = placeholder + String(placeholder[placeholder.startIndex])
            } else {
                return nil
            }
            str += char
            let index_str = placeholder + String(char[char.startIndex])
            dic[dic.count+1] = index_str
            placeholder = char
        }
        
        return str
    }
}
