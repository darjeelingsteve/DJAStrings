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

// MARK: - LocalisationsTreeNode

extension LocalisationGroup: LocalisationsTreeNode {
    var childNodes: [LocalisationGroup] {
        childGroups
    }
}

private extension Localisation {
    init?(key: String, documentLocalisation: XCStringsDocument.StringLocalisation, sourceLanguage: String, tableName: String) throws {
        guard key.isSuitableSwiftSymbol else { return nil }
        guard !(documentLocalisation.comment ?? "").contains("ObjectID =") else {
            /// Ignore localisations from XIB files.
            return nil
        }
        self.key = key
        self.tableName = tableName
        let sourceLanguageLocalisation = documentLocalisation.localisations?[sourceLanguage]
        switch sourceLanguageLocalisation {
        case let .stringUnit(stringUnit, substitutions):
            if let substitutions {
                placeholders = try substitutions.placeholders
            } else {
                placeholders = try stringUnit.value.placeholders
            }
        case let .variations(variations, _):
            switch variations {
            case let .plural(plural):
                placeholders = try plural.populatedVariations.map { $0.variation }.placeholders
            case let .device(device):
                placeholders = try device.populatedVariations.map { $0.variation }.placeholders
            case .width:
                placeholders = []
            }
        case .none:
            placeholders = []
        }
        switch sourceLanguageLocalisation {
        case let .stringUnit(stringUnit, substitutions):
            if let substitutions {
                previews = substitutions.previews(forSourceLanguageLocalisedString: stringUnit.value)
            } else {
                previews = [Preview(description: nil, value: stringUnit.value)]
            }
        case let .variations(variations, substitutions):
            switch variations {
            case let .plural(plural):
                previews = plural.populatedVariations.previews
            case let .device(device):
                if let substitutions {
                    previews = device.populatedVariations.flatMap { substitutions.previews(forSourceLanguageLocalisedString: $0.variation.stringUnit.value, descriptionPrefix: "Device \($0.name)") }
                } else {
                    previews = device.populatedVariations.previews
                }
            case let .width(widths):
                let orderedKeys = widths.keys.sorted(using: .localizedStandard)
                if let substitutions {
                    previews = orderedKeys.flatMap { substitutions.previews(forSourceLanguageLocalisedString: widths[$0]!.stringUnit.value, descriptionPrefix: "Width \($0)") }
                } else {
                    previews = orderedKeys.map { Preview(description: "Width \($0)", value: widths[$0]!.stringUnit.value) }
                }
            }
        case .none:
            previews = []
        }
    }
}

private extension Dictionary where Key == String, Value == XCStringsDocument.StringLocalisation.Localisation.Substitution {
    var placeholders: [Localisation.Placeholder] {
        get throws {
            let flattenedSubstitutions: [(key: String, argumentNumber: Int, formatSpecifier: String)] = reduce(into: []) { partialResult, substituionPair in
                partialResult.append((key: substituionPair.key,
                                      argumentNumber: substituionPair.value.argumentNumber,
                                      formatSpecifier: substituionPair.value.formatSpecifier))
            }
            return try flattenedSubstitutions
                .sorted(by: { $0.argumentNumber < $1.argumentNumber })
                .map { flattenedSubstitution in
                    Localisation.Placeholder(name: flattenedSubstitution.key,
                                             type: try Localisation.Placeholder.DataType(formatSpecifier: flattenedSubstitution.formatSpecifier))
                }
        }
    }
    
    func previews(forSourceLanguageLocalisedString sourceLanguageLocalisedString: String, descriptionPrefix: String? = nil) -> [Localisation.Preview] {
        let includedInSource = filter { sourceLanguageLocalisedString.contains($0.key.asSubstitutionPlaceholder) }
        let argumentNameAndPreviews = includedInSource.sorted(by: { $0.value.argumentNumber < $1.value.argumentNumber }).map { ArgumentNameAndPreviews(argumentName: $0.key, substitution: $0.value) }
        guard let firstArgumentNameAndPreviews = argumentNameAndPreviews.first else { return [] }
        
        let previewDescriptionPrefix = descriptionPrefix != nil ? descriptionPrefix!.appending(", ") : ""
        
        /// Build an array of localised values using the localised values for
        /// the localisation's first argument.
        var localisedValues = firstArgumentNameAndPreviews.previews.map { Localisation.Preview(description: $0.description != nil ? previewDescriptionPrefix + $0.description! : nil,
                                                                                               value: sourceLanguageLocalisedString.replacing(localisationArgumentName: firstArgumentNameAndPreviews.argumentName, with: $0.value)) }
        /// For each subsequent argument, create a copy of the existing
        /// localised values, multiplied by the number of localised values
        /// belonging to the argument. Then, apply each of the arguments
        /// localised values to the elements in the multiplied array.
        argumentNameAndPreviews.dropFirst().forEach { argumentNameAndLocalisedValue in
            localisedValues = Array(repeatingElementsOf: localisedValues, count: argumentNameAndLocalisedValue.previews.count)
            for index in 0..<localisedValues.count {
                let localisedValue = argumentNameAndLocalisedValue.previews[index % argumentNameAndLocalisedValue.previews.count]
                localisedValues[index] = Localisation.Preview(description: (localisedValues[index].description ?? "") + ", \(localisedValue.description ?? "")",
                                                              value: localisedValues[index].value.replacing(localisationArgumentName: argumentNameAndLocalisedValue.argumentName, with: localisedValue.value))
            }
        }
        return localisedValues
    }
    
    private struct ArgumentNameAndPreviews {
        let argumentName: String
        let previews: [Localisation.Preview]
        
        init(argumentName: String, substitution: XCStringsDocument.StringLocalisation.Localisation.Substitution) {
            self.argumentName = argumentName
            switch substitution.variations {
            case let .plural(plural):
                previews = plural.populatedVariations.previews.map { Localisation.Preview(description: "\(argumentName.camelCased()) \($0.description ?? "")",
                                                                                          value: $0.value.replacingOccurrences(of: "%arg", with: "`\(argumentName.camelCased())`")) }
            case let .device(device):
                previews = device.populatedVariations.previews.map { Localisation.Preview(description: "\(argumentName.camelCased()) \($0.description ?? "")",
                                                                                          value: $0.value.replacingOccurrences(of: "%arg", with: "`\(argumentName.camelCased())`")) }
            case .width:
                fatalError("Substitution arguments cannot be varied by width")
            }
        }
    }
}

private extension XCStringsDocument.StringLocalisation.Localisation.Variations.Plural {
    var populatedVariations: [NamedVariation] {
        var populatedVariations = [NamedVariation]()
        if let zero {
            populatedVariations.append(NamedVariation(name: "Zero", variation: zero))
        }
        if let one {
            populatedVariations.append(NamedVariation(name: "One", variation: one))
        }
        if let two {
            populatedVariations.append(NamedVariation(name: "Two", variation: two))
        }
        if let few {
            populatedVariations.append(NamedVariation(name: "Few", variation: few))
        }
        if let many {
            populatedVariations.append(NamedVariation(name: "Many", variation: many))
        }
        populatedVariations.append(NamedVariation(name: "Other", variation: other))
        return populatedVariations
    }
}

private extension XCStringsDocument.StringLocalisation.Localisation.Variations.Device {
    var populatedVariations: [NamedVariation] {
        var populatedVariations = [NamedVariation]()
        if let iPhone {
            populatedVariations.append(NamedVariation(name: "iPhone", variation: iPhone))
        }
        if let iPod {
            populatedVariations.append(NamedVariation(name: "iPod", variation: iPod))
        }
        if let iPad {
            populatedVariations.append(NamedVariation(name: "iPad", variation: iPad))
        }
        if let appleWatch {
            populatedVariations.append(NamedVariation(name: "Apple Watch", variation: appleWatch))
        }
        if let appleTV {
            populatedVariations.append(NamedVariation(name: "Apple TV", variation: appleTV))
        }
        if let mac {
            populatedVariations.append(NamedVariation(name: "Mac", variation: mac))
        }
        if let other {
            populatedVariations.append(NamedVariation(name: "Other", variation: other))
        }
        return populatedVariations
    }
}

private struct NamedVariation {
    let name: String
    let variation: XCStringsDocument.StringLocalisation.Localisation.Variations.Variation
}

private extension Array where Element == XCStringsDocument.StringLocalisation.Localisation.Variations.Variation? {
    var placeholders: [Localisation.Placeholder] {
        get throws {
            let variationPlaceholders = try compactMap { try $0?.stringUnit.value.placeholders }
                .sorted(by: { $0.count < $1.count })
            return variationPlaceholders.last ?? []
        }
    }
}

private extension Array where Element == NamedVariation {
    var previews: [Localisation.Preview] {
        map { Localisation.Preview(description: $0.name, value: $0.variation.stringUnit.value) }
    }
}

// MARK: - String Extensions

private extension String {
    private static let placeholdersRegex: Regex = {
        let allFormatCharacters = Localisation.Placeholder.DataType.allCases.flatMap { $0.formatCharacters }
        return try! Regex("[%](.*?)[\(allFormatCharacters)]")
    }()
    
    var isSuitableSwiftSymbol: Bool {
        rangeOfCharacter(from: .whitespaces) == nil
    }
    
    var placeholders: [Localisation.Placeholder] {
        get throws {
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
            
            return try placeholderDataTypes(fromFormatCharacters: formatCharacters).map { Localisation.Placeholder(name: nil, type: $0) }
        }
    }
    
    var asSubstitutionPlaceholder: String {
        "%#@\(self)@"
    }
    
    func replacing(localisationArgumentName: String, with value: String) -> String {
        replacingOccurrences(of: localisationArgumentName.asSubstitutionPlaceholder, with: value)
    }
    
    /// Creates an array of
    /// `LocalisationGroup.Localisation.Placeholder.DataType` from an array of
    /// format characters and their positional specifier, if present.
    /// - Parameter formatCharacters: An array of format characters and their
    /// optional positional specifier.
    /// - Returns: An array of placeholder data types corresponding to the given
    /// format characters and position specifiers.
    private func placeholderDataTypes(fromFormatCharacters formatCharacters: [(Character, Int?)]) throws -> [Localisation.Placeholder.DataType] {
        var positionsAndDataTypes = [Int: Localisation.Placeholder.DataType]()
        var nextNonPositionalIndex = 1
        
        for (character, positionalSpecifier) in formatCharacters {
            guard let placeholderType = try? Localisation.Placeholder.DataType(formatCharacter: character) else { continue }
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

// MARK: - Array Extensions

private extension Array {
    init(repeatingElementsOf array: [Element], count: Int) {
        self.init(array.flatMap { element in
            Array(repeating: element, count: array.count)
        })
    }
}

// MARK: - Errors

extension LocalisationGroup {
    
    /// Errors that occur when parsing a localisation group.
    enum ParsingError: Error, LocalizedError {
        case invalidPlaceholder(index: Int, previousDataType: Localisation.Placeholder.DataType, newDataType: Localisation.Placeholder.DataType)
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
