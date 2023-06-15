//
//  SwiftCodeGenerator.swift
//
//
//  Created by Stephen Anthony on 14/06/2023.
//

import Foundation
import SwiftFormat

/// The code generator for producing Swift code from a localisations tree.
final class SwiftCodeGenerator {
    
    /// The generated Swift source from the receiver's localisation tree.
    var swiftSource: String {
        get throws {
            let rawSource = """
            import Foundation
            \(rootLocalisationsTreeNode.swiftRepresentation)
            """
            var output = ""
            let formatter = try SwiftFormatter(configuration: .init(contentsOf: Bundle.module.url(forResource: "Default", withExtension: "swift-format")!))
            try formatter.format(source: rawSource, assumingFileURL: nil, to: &output)
            return output
        }
    }
    
    private let rootLocalisationsTreeNode: LocalisationsTreeNode
    
    init(rootLocalisationsTreeNode: LocalisationsTreeNode) {
        self.rootLocalisationsTreeNode = rootLocalisationsTreeNode
    }
}

private extension LocalisationsTreeNode {
    var swiftRepresentation: String {
        var swiftRepresentation = """
public enum \(name.titleCased()) {
\(localisations.map { $0.swiftRepresentation }.joined(separator: "\n\n"))
"""
        if !childNodes.isEmpty {
            if !localisations.isEmpty {
                swiftRepresentation.append("\n\n")
            }
            swiftRepresentation.append(childNodes.map { $0.swiftRepresentation }.joined(separator: "\n\n"))
        }
        swiftRepresentation.append("}")
        return swiftRepresentation
    }
}

private extension Localisation {
    var swiftRepresentation: String {
        let symbolName = (key.components(separatedBy: ".").last ?? key).camelCased()
        if placeholders.isEmpty {
            return "static let \(symbolName) = NSLocalizedString(\"\(key)\", tableName: \"\(tableName)\", comment: \"\")"
        } else {
            return """
static func \(symbolName)(\(placeholderFunctionParameters)) -> String {
    String(format: NSLocalizedString(\"\(key)\", tableName: \"\(tableName)\", comment: \"\"), \(placeholderVarArgs))
}
"""
        }
    }
    
    private var placeholderFunctionParameters: String {
        placeholders.enumerated().map { index, parameter in
            "\(parameter.name?.camelCased() ?? "_ p\(index.description)"): \(parameter.type.swiftTypeName)"
        }.joined(separator: ", ")
    }
    
    private var placeholderVarArgs: String {
        placeholders.enumerated().map { index, parameter in
            let parameterName = parameter.name?.camelCased() ?? "p\(index.description)"
            switch parameter.type {
            case .object:
                return parameterName + ".description"
            default :
                return parameterName
            }
        }.joined(separator: ", ")
    }
}

private extension Localisation.Placeholder.DataType {
    var swiftTypeName: String {
        switch self {
        case .object:
            return "CustomStringConvertible"
        case .float:
            return "Float"
        case .integer:
            return "Int"
        case .unsignedInteger:
            return "UInt"
        case .char:
            return "CChar"
        case .cString:
            return "UnsafePointer<CChar>"
        case .pointer:
            return "UnsafeRawPointer"
        }
    }
}

private extension String {
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
