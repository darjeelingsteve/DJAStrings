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
