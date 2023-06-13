//
//  LocalisationGroup.swift
//
//
//  Created by Stephen Anthony on 12/06/2023.
//

import Foundation

/// Represents a group of localisations, modelled as a tree of groups and
/// subgroups.
final class LocalisationGroup {
    
    /// The name of the group.
    let name: String
    
    /// The localisations contained within the group.
    private(set) var localisations = [Localisation]()
    
    /// The child groups of the group.
    private(set) var childGroups = [LocalisationGroup]()
    
    /// An individual localisation.
    struct Localisation {
        
        /// The key used to look up the localisation in its parent localisation
        /// table.
        let key: String
        
        /// The name of the table containing `key`.
        let tableName: String
        
        /// The placeholders contained within the 
        let placeholders: [Placeholder]
        
        /// A placeholder in a localised format string.
        struct Placeholder {
            
            /// The name of the placeholder, if any.
            let name: String?
            
            /// The data type of the placeholder.
            let type: DataType
        }
    }
    
    /// Creates a new group with the given name.
    /// - Parameter name: The name of the group.
    init(name: String) {
        self.name = name
    }
    
    /// Applies the localisations from the parsed strings document to the
    /// receiver. Only localisations with keys suitable for tokenisation will be
    /// included. Keys containing namespaces will be broken up by namespace in
    /// to child groups of the receiver.
    /// - Parameter document: The parsed document from which to obtain
    /// localisation details.
    func applying(document: ParsedStringsDocument) throws {
        let localisations = try document.stringsDocument.strings.sorted(by: { $0.key < $1.key }).compactMap { key, documentLocalisation in
            try Localisation(key: key, documentLocalisation: documentLocalisation, sourceLanguage: document.stringsDocument.sourceLanguage, tableName: document.tableName)
        }
        localisations.forEach { localisation in
            var groupForLocalisation = self
            let namespaceComponents = localisation.key.components(separatedBy: ".").dropLast()
            namespaceComponents.forEach { namespaceComponent in
                groupForLocalisation = groupForLocalisation.childGroup(forName: namespaceComponent)
            }
            groupForLocalisation.localisations.append(localisation)
        }
    }
    
    private func childGroup(forName name: String) -> LocalisationGroup {
        if let childGroup = childGroups.first(where: { $0.name == name }) {
            return childGroup
        }
        let childGroup = LocalisationGroup(name: name)
        childGroups.append(childGroup)
        return childGroup
    }
}

extension LocalisationGroup.Localisation {
    init?(key: String, documentLocalisation: XCStringsDocument.StringLocalisation, sourceLanguage: String, tableName: String) throws {
        guard key.isSuitableSwiftSymbol else { return nil }
        guard !(documentLocalisation.comment ?? "").contains("ObjectID =") else {
            /// Ignore localisations from XIB files.
            return nil
        }
        self.key = key
        self.tableName = tableName
        switch documentLocalisation.localisations?[sourceLanguage] {
        case let .stringUnit(stringUnit, substitutions):
            if let substitutions {
                placeholders = try substitutions.placeholders()
            } else {
                placeholders = try stringUnit.value.placeholders()
            }
        case let .variations(variations):
            switch variations {
            case let .plural(plural):
                /// Use the variation with the greatest number of placeholders.
                let allVariations = [plural.zero, plural.one, plural.two, plural.few, plural.many, plural.other]
                let variationPlaceholders = try allVariations
                    .compactMap { try $0?.stringUnit.value.placeholders() }
                    .sorted(by: { $0.count < $1.count })
                placeholders = variationPlaceholders.last ?? []
            case .width:
                placeholders = []
            }
        case .none:
            placeholders = []
        }
    }
}

// MARK: - LocalisationGroup.Localisation.Placeholder.DataType

extension LocalisationGroup.Localisation.Placeholder {
    
    /// The different data types that can be represented by placeholders in
    /// localised format string.
    enum DataType: CaseIterable {
        case object
        case float
        case integer
        case unsignedInteger
        case char
        case cString
        case pointer
        
        var formatCharacters: [Character] {
            switch self {
            case .object:
                return ["@"]
            case .float:
                return ["a", "e", "f", "g"]
            case .integer:
                return ["d", "i", "o", "x"]
            case .unsignedInteger:
                return ["u"]
            case .char:
                return ["c"]
            case .cString:
                return ["s"]
            case .pointer:
                return ["p"]
            }
        }
        
        init(formatCharacter character: Character) throws {
            let lowercased = String(character).lowercased()
            for dataType in DataType.allCases {
                if dataType.formatCharacters.contains(lowercased) {
                    self = dataType
                    return
                }
            }
            throw LocalisationGroup.ParsingError.unsupportedFormatCharacter(character)
        }
        
        init(formatSpecifier: String) throws {
            guard let formatCharacter = formatSpecifier.last else {
                throw LocalisationGroup.ParsingError.unsupportedFormatSpecifier(formatSpecifier)
            }
            try self.init(formatCharacter: formatCharacter)
        }
    }
}

private extension Dictionary where Key == String, Value == XCStringsDocument.StringLocalisation.Localisation.Substitution {
    func placeholders() throws -> [LocalisationGroup.Localisation.Placeholder] {
        let flattenedSubstitutions: [(key: String, argumentNumber: Int, formatSpecifier: String)] = reduce(into: []) { partialResult, substituionPair in
            partialResult.append((key: substituionPair.key,
                                  argumentNumber: substituionPair.value.argumentNumber,
                                  formatSpecifier: substituionPair.value.formatSpecifier))
        }
        return try flattenedSubstitutions
            .sorted(by: { $0.argumentNumber < $1.argumentNumber })
            .map { flattenedSubstitution in
                LocalisationGroup.Localisation.Placeholder(name: flattenedSubstitution.key,
                                                           type: try LocalisationGroup.Localisation.Placeholder.DataType(formatSpecifier: flattenedSubstitution.formatSpecifier))
            }
    }
}

// MARK: - String Extensions

private extension String {
    private static let placeholdersRegex: Regex = {
        let allFormatCharacters = LocalisationGroup.Localisation.Placeholder.DataType.allCases.flatMap { $0.formatCharacters }
        return try! Regex("[%](.*?)[\(allFormatCharacters)]")
    }()
    
    var isSuitableSwiftSymbol: Bool {
        rangeOfCharacter(from: .whitespaces) == nil
    }
    
    func placeholders() throws -> [LocalisationGroup.Localisation.Placeholder] {
        let matches = matches(of: String.placeholdersRegex)
        guard !matches.isEmpty else { return [] }
        let formatCharacters: [(Character, Int?)] = matches.compactMap { match in
            let matchedSubstring = self[match.range]
            guard let formatCharacter = matchedSubstring.last else { return nil }
            let removedPercentAndFormatCharacters = matchedSubstring.dropFirst().dropLast()
            guard let dollarIndex = removedPercentAndFormatCharacters.firstIndex(of: "$"), let positionalSpecifier = Int(removedPercentAndFormatCharacters[removedPercentAndFormatCharacters.startIndex..<dollarIndex]) else {
                return (formatCharacter, nil)
            }
            return (formatCharacter, positionalSpecifier)
        }
        
        return try placeholderDataTypes(fromFormatCharacters: formatCharacters).map { LocalisationGroup.Localisation.Placeholder(name: nil, type: $0) }
    }
    
    /// Creates an array of
    /// `LocalisationGroup.Localisation.Placeholder.DataType` from an array of
    /// format characters and their positional specifier, if present.
    /// - Parameter formatCharacters: An array of format characters and their
    /// optional positional specifier.
    /// - Returns: An array of placeholder data types corresponding to the given
    /// format characters and position specifiers.
    private func placeholderDataTypes(fromFormatCharacters formatCharacters: [(Character, Int?)]) throws -> [LocalisationGroup.Localisation.Placeholder.DataType] {
        var positionsAndDataTypes = [Int: LocalisationGroup.Localisation.Placeholder.DataType]()
        var nextNonPositionalIndex = 1
        
        for (character, positionalSpecifier) in formatCharacters {
            guard let placeholderType = try? LocalisationGroup.Localisation.Placeholder.DataType(formatCharacter: character) else { continue }
            let index: Int
            if let positionalSpecifier {
                index = positionalSpecifier
            } else {
                index = nextNonPositionalIndex
                nextNonPositionalIndex += 1
            }
            guard index > 0 else { continue }
            
            if let existingEntry = positionsAndDataTypes[index], existingEntry != placeholderType {
                throw LocalisationGroup.ParsingError.invalidPlaceholder(index: index,
                                                                        previousDataType: existingEntry,
                                                                        newDataType: placeholderType)
            } else {
                positionsAndDataTypes[index] = placeholderType
            }
        }
        
        return positionsAndDataTypes
            .sorted { $0.0 < $1.0 }
            .map { $0.value }
    }
}

// MARK: - Errors

extension LocalisationGroup {
    
    /// Errors that occur when parsing a localisation group.
    enum ParsingError: Error, LocalizedError {
        case invalidPlaceholder(index: Int, previousDataType: LocalisationGroup.Localisation.Placeholder.DataType, newDataType: LocalisationGroup.Localisation.Placeholder.DataType)
        case unsupportedFormatCharacter(_: Character)
        case unsupportedFormatSpecifier(_: String)
        
        var errorDescription: String? {
            switch self {
            case let .invalidPlaceholder(index, previousDataType, newDataType):
                return "Invalid placeholder at index: \(index): would overwrite previous placeholder data type of \(previousDataType) with \(newDataType)"
            case let .unsupportedFormatCharacter(character):
                return "Unsupported format character: \(character)"
            case let .unsupportedFormatSpecifier(formatSpecifier):
                return "Unsupported format specifier: \(formatSpecifier)"
            }
        }
    }
}
