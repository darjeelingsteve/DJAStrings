//
//  SwiftCodeGenerator.swift
//
//
//  Created by Stephen Anthony on 14/06/2023.
//

import Foundation
import SwiftFormat
import SwiftFormatConfiguration

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
            let formatter = try SwiftFormatter(configuration: formatConfiguration)
            try formatter.format(source: rawSource, assumingFileURL: nil, to: &output)
            return output
        }
    }
    
    private let rootLocalisationsTreeNode: LocalisationsTreeNode
    private let formattingConfigurationFileURL: URL?
    
    private var formatConfiguration: SwiftFormatConfiguration.Configuration {
        get throws {
            if let formattingConfigurationFileURL {
                return try SwiftFormatConfiguration.Configuration(contentsOf: formattingConfigurationFileURL)
            } else {
                var configuration = Configuration()
                configuration.indentation = .spaces(4)
                configuration.lineLength = 10_000
                return configuration
            }
        }
    }
    
    init(rootLocalisationsTreeNode: LocalisationsTreeNode, formattingConfigurationFileURL: URL?) {
        self.rootLocalisationsTreeNode = rootLocalisationsTreeNode
        self.formattingConfigurationFileURL = formattingConfigurationFileURL
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
            return """
\(documentationComment)
static let \(symbolName) = NSLocalizedString(\"\(key)\", tableName: \"\(tableName)\", comment: \"\")
"""
        } else {
            return """
\(documentationComment)
static func \(symbolName)(\(placeholderFunctionParameters)) -> String {
    String(format: NSLocalizedString(\"\(key)\", tableName: \"\(tableName)\", comment: \"\"), \(placeholderVarArgs))
}
"""
        }
    }
    
    private var documentationComment: String {
        let previewsComments = previews.map { $0.documentationComment }.joined(separator: "\n///\n")
        guard previews.count >= 2 else {
            return previewsComments
        }
        return """
/// Key: `\(key)`, table name: `\(tableName)`
///
\(previewsComments)
"""
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

private extension Localisation.Preview {
    var documentationComment: String {
        let valueComment = "/// \(value)"
        guard let description else {
            return valueComment
        }
        return "/// **\(description)**\n\(valueComment)"
    }
}
