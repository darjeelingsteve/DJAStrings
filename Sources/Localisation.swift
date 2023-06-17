//
//  Localisation.swift
//  
//
//  Created by Stephen Anthony on 15/06/2023.
//

import Foundation

/// An individual localisation.
struct Localisation {
    
    /// The key used to look up the localisation in its parent localisation
    /// table.
    let key: String
    
    /// The name of the table containing `key`.
    let tableName: String
    
    /// The placeholders contained within the localisation.
    let placeholders: [Placeholder]
    
    /// The different values associated with the localisation, in the source
    /// language. Standard localisations without variations will have a single
    /// value, whereas localisations with plural or width variations will have a
    /// value for each variation.
    let localisedValues: [LocalisedValue]
}

// MARK: - Localisation.Placeholder

extension Localisation {
    /// A placeholder in a localised format string.
    struct Placeholder {
        
        /// The name of the placeholder, if any.
        let name: String?
        
        /// The data type of the placeholder.
        let type: DataType
    }
}

// MARK: - Localisation.LocalisedValue

extension Localisation {
    
    /// An individual localised value for a localisation.
    struct LocalisedValue {
        
        /// The description of the value. `nil` for the default value of a
        /// localisation containing no variations.
        let description: String?
        
        /// The localised value.
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
