//
//  String+Extensions.swift
//
//
//  Created by Stephen Anthony on 17/06/2023.
//

import Foundation

extension String {
    private static let swiftKeywords = [
        "as",
        "associatedtype",
        "break",
        "case",
        "catch",
        "class",
        "continue",
        "default",
        "defer",
        "deinit",
        "do",
        "else",
        "enum",
        "extension",
        "fallthrough",
        "false",
        "fileprivate",
        "for",
        "func",
        "guard",
        "if",
        "import",
        "in",
        "init",
        "inout",
        "internal",
        "is",
        "let",
        "nil",
        "open",
        "operator",
        "precedencegroup",
        "private",
        "protocol",
        "public",
        "repeat",
        "rethrows",
        "return",
        "self",
        "Self",
        "static",
        "struct",
        "subscript",
        "super",
        "switch",
        "throw",
        "throws",
        "true",
        "try",
        "typealias",
        "var",
        "where",
        "while"
    ]
    
    func camelCased() -> String {
        components(separatedBy: .keyComponentSeparators).enumerated().map{ element -> String in
            let token = element.element
            return firstCharacter(forToken: token, atIndex: element.offset) + token.dropFirst()
        }.joined()
    }
    
    func titleCased() -> String {
        components(separatedBy: .keyComponentSeparators).enumerated().map { element -> String in
            let token = element.element
            return token.prefix(1).uppercased() + token.dropFirst()
        }.joined()
    }
    
    func snakeCased() -> String {
        let alphanumericsAndWhitespace = CharacterSet.alphanumerics.union(.whitespaces)
        let nonAlphanumericOrWhitespaceStripped = String(unicodeScalars.filter(alphanumericsAndWhitespace.contains))
        return nonAlphanumericOrWhitespaceStripped.components(separatedBy: .whitespaces).enumerated().map { element -> String in
            let token = element.element
            return token.prefix(1).lowercased() + token.dropFirst()
        }.joined(separator: "_")
    }
    
    func backtickedIfNeeded() -> String {
        guard String.swiftKeywords.contains(self) else { return self }
        return "`\(self)`"
    }
    
    private func firstCharacter(forToken token: String, atIndex index: Int) -> String {
        if index == 0 {
            return token.prefix(1).lowercased()
        } else {
            return token.prefix(1).uppercased()
        }
    }
}

private extension CharacterSet {
    static let keyComponentSeparators = CharacterSet.whitespacesAndNewlines.union(["_", "-", "—"])
}
