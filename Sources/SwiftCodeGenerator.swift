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
            \(rootLocalisationsTreeNode.swiftRepresentation(forResourceBundleLocationKind: resourceBundleLocationKind))
            
            \(resourceBundleLocationKind.djaLocalizedStringFunction)
            """
            var output = ""
            let formatter = try SwiftFormatter(configuration: formatConfiguration)
            try formatter.format(source: rawSource, assumingFileURL: nil, to: &output)
            return output
        }
    }
    
    private let rootLocalisationsTreeNode: LocalisationsTreeNode
    private let resourceBundleLocationKind: ResourceBundleLocationKind
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
    
    init(rootLocalisationsTreeNode: LocalisationsTreeNode, resourceBundleLocationKind: ResourceBundleLocationKind, formattingConfigurationFileURL: URL?) {
        self.rootLocalisationsTreeNode = rootLocalisationsTreeNode
        self.resourceBundleLocationKind = resourceBundleLocationKind
        self.formattingConfigurationFileURL = formattingConfigurationFileURL
    }
}

private extension LocalisationsTreeNode {
    func swiftRepresentation(forResourceBundleLocationKind resourceBundleLocationKind: ResourceBundleLocationKind) -> String {
        var swiftRepresentation = """
public enum \(name.titleCased()) {
\(localisations.sorted(by: { $0.key < $1.key }).map { $0.swiftRepresentation(forResourceBundleLocationKind: resourceBundleLocationKind) }.joined(separator: "\n\n"))
"""
        if !childNodes.isEmpty {
            if !localisations.isEmpty {
                swiftRepresentation.append("\n\n")
            }
            swiftRepresentation.append(childNodes.sorted(by: { $0.name < $1.name }).map { $0.swiftRepresentation(forResourceBundleLocationKind: resourceBundleLocationKind) }.joined(separator: "\n\n"))
        }
        swiftRepresentation.append("}")
        return swiftRepresentation
    }
}

private extension Localisation {
    func swiftRepresentation(forResourceBundleLocationKind resourceBundleLocationKind: ResourceBundleLocationKind) -> String {
        let symbolName = (key.components(separatedBy: ".").last ?? key).camelCased().backtickedIfNeeded()
        let formattedComment = comment?.components(separatedBy: .newlines).joined(separator: " ")
        let defaultLanguageValue = self.defaultLanguageValue?
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let inlineBundleParameter = extractionState.inlineBundleParameter(forResourceBundleLocationKind: resourceBundleLocationKind)
        let localizedStringParameters = [
            "\"\(key)\"",
            "tableName: \"\(tableName)\"",
            inlineBundleParameter != nil ? "bundle: \(inlineBundleParameter!)" : nil,
            defaultLanguageValue != nil ? " value: \"\(defaultLanguageValue!)\"" : nil,
            "comment: \"\(formattedComment ?? "")\""
        ]
        let localizedStringFunctionCall = "\(extractionState.localizedStringFunctionName)(\(localizedStringParameters.compactMap { $0 }.joined(separator: ", ")))"
        if placeholders.isEmpty {
            return """
\(documentationComment(withLocalisationComment: formattedComment))
static let \(symbolName) = \(localizedStringFunctionCall)
"""
        } else {
            return """
\(documentationComment(withLocalisationComment: formattedComment))
static func \(symbolName)(\(placeholderFunctionParameters)) -> Swift.String {
    Swift.String.localizedStringWithFormat(\(localizedStringFunctionCall), \(placeholderVarArgs))
}
"""
        }
    }
    
    private func documentationComment(withLocalisationComment localisationComment: String?) -> String {
        let previewsCommentComponents = previews.map { $0.documentationComment }
        let allCommentComponents = previewsCommentComponents + [localisationComment != nil ? "/// **Comment**\n/// \(localisationComment!)" : nil].compactMap { $0 }
        let allCommentsString = allCommentComponents.joined(separator: "\n///\n")
        guard previewsCommentComponents.count > 1 else {
            /// We only have one preview, which is likely to be the
            /// localisation's translated value, so format our documentation so
            /// that it is the primary content displayed during autocompletion.
            return allCommentsString
        }
        /// We have multiple previews, so make the primary documentation content
        /// be the string key and table name, with the previews and possible
        /// comment displayed in the "Discussion" section.
        return """
/// Key: `\(key)`, table name: `\(tableName)`
///
\(allCommentsString)
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

private extension Optional where Wrapped == Localisation.ExtractionState {
    var localizedStringFunctionName: String {
        switch self {
        case .migrated, .manual, .stale:
            return "DJALocalizedString"
        case .extractedWithValue, .none:
            return "NSLocalizedString"
        }
    }
    
    func inlineBundleParameter(forResourceBundleLocationKind resourceBundleLocationKind: ResourceBundleLocationKind) -> String? {
        switch self {
        case .migrated, .manual, .stale:
            nil
        case .extractedWithValue, .none:
            resourceBundleLocationKind.bundle
        }
    }
}

private extension Localisation.Placeholder.DataType {
    var swiftTypeName: String {
        switch self {
        case .object:
            return "CustomStringConvertible"
        case .float:
            return "Double"
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
        let valueComment = "/// \(value.replacingOccurrences(of: "\n", with: " "))"
        guard let description else {
            return valueComment
        }
        return "/// **\(description)**\n\(valueComment)"
    }
}

private extension ResourceBundleLocationKind {
    static let StringsBundleClassName = "DJAStringsBundleClass"
    
    var bundle: String {
        switch self {
        case .standard:
            "Bundle(for: \(ResourceBundleLocationKind.StringsBundleClassName).self)"
        case .swiftPackage:
            "Bundle.module"
        }
    }
    
    var djaLocalizedStringFunction: String {
        switch self {
        case .standard:
            """
            private final class \(ResourceBundleLocationKind.StringsBundleClassName) {}
            
            private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
                NSLocalizedString(key, tableName: tableName, bundle: \(bundle), value: value, comment: comment)
            }
            """
        case .swiftPackage:
            """
            private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
                NSLocalizedString(key, tableName: tableName, bundle: \(bundle), value: value, comment: comment)
            }
            """
        }
    }
}
