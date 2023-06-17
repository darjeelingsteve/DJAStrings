//
//  String+Extensions.swift
//
//
//  Created by Stephen Anthony on 17/06/2023.
//

import Foundation

extension String {
    func camelCased() -> String {
        components(separatedBy: "_").enumerated().map({ element -> String in
            let token = element.element
            return firstCharacter(forToken: token, atIndex: element.offset) + token.dropFirst()
        }).joined()
    }
    
    func titleCased() -> String {
        components(separatedBy: "_").enumerated().map({ element -> String in
            let token = element.element
            return token.prefix(1).uppercased() + token.dropFirst()
        }).joined()
    }
    
    private func firstCharacter(forToken token: String, atIndex index: Int) -> String {
        if index == 0 {
            return token.prefix(1).lowercased()
        } else {
            return token.prefix(1).uppercased()
        }
    }
}
