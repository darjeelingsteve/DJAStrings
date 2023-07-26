//
//  Localisation.swift
//  
//
//  Created by Stephen Anthony on 15/06/2023.
//

import Foundation

/// An individual localisation.
struct Localisation: Equatable {
    
    /// The key used to look up the localisation in its parent localisation
    /// table.
    let key: String
    
    /// The name of the table containing `key`.
    let tableName: String
    
    /// The value of the localisation in the default development language, if
    /// any. Localisations whose value is a variation (e.g by device or plural)
    /// will return `nil` for this property.
    let defaultLanguageValue: String?
    
    /// The comment assigned to the localisation, if any.
    let comment: String?
    
    /// The placeholders contained within the localisation.
    let placeholders: [Placeholder]
    
    /// Preview of the different variations associated with the localisation,
    /// in the source language. Standard localisations without variations will
    /// have a single preview, whereas localisations with plural or width
    /// variations will have a preview for each variation.
    let previews: [Preview]
}

// MARK: - Localisation.Placeholder

extension Localisation {
    /// A placeholder in a localised format string.
    struct Placeholder: Equatable {
        
        /// The name of the placeholder, if any.
        let name: String?
        
        /// The data type of the placeholder.
        let type: DataType
    }
}

// MARK: - Localisation.Preview

extension Localisation {
    
    /// A preview of an individual variant of a localisation.
    struct Preview: Equatable {
        
        /// The description of the preview. `nil` for the default value of a
        /// localisation containing no variations.
        let description: String?
        
        /// A preview of how the localisation will appear.
        let value: String
    }
}

// MARK: - Localisation.Placeholder.DataType

extension Localisation.Placeholder {
    
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
            throw DJAStringsError.unsupportedFormatCharacter(character)
        }
        
        init(formatSpecifier: String) throws {
            guard let formatCharacter = formatSpecifier.last else {
                throw DJAStringsError.unsupportedFormatSpecifier(formatSpecifier)
            }
            try self.init(formatCharacter: formatCharacter)
        }
    }
}
