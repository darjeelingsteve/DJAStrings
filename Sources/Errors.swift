//
//  Errors.swift
//
//
//  Created by Stephen Anthony on 27/06/2023.
//

import Foundation

/// The errors produced by DJAStrings.
enum DJAStringsError: Error, LocalizedError {
    /// Thrown when an invalid top-level localisation namespace is provided.
    case invalidTopLevelLocalisationNamespace(_ topLevelLocalisationNamespace: String)
    
    /// Thrown when an `.xcstrings` file contains a kind of localisation that
    /// cannot be parsed by DJAStrings.
    case unrecognisedLocalisationType
    
    /// Thrown when an `.xcstrings` file contains a localisation variation type
    /// that cannot be parsed by DJAStrings.
    case unrecognisedVariationType
    
    /// Thrown when a localisation contains multiple placeholders for the same
    /// position i.e two placeholders with the same position specifier.
    case invalidPlaceholder(index: Int, previousDataType: Localisation.Placeholder.DataType, newDataType: Localisation.Placeholder.DataType)
    
    /// Thrown when a localisation placeholder contains a character that does
    /// not map to a supported placeholder type.
    case unsupportedFormatCharacter(_: Character)
    
    /// Thrown when a localisation contains a placeholder that cannot be parsed.
    case unsupportedFormatSpecifier(_: String)
    
    var errorDescription: String? {
        switch self {
        case let .invalidTopLevelLocalisationNamespace(topLevelLocalisationNamespace):
            return "Invalid top-level localisation namespace: \"\(topLevelLocalisationNamespace)\". The top level namespace must only contain alphanumerics."
        case .unrecognisedLocalisationType:
            return "Unrecognised localisation type"
        case .unrecognisedVariationType:
            return "Unrecognised localisation variation type"
        case let .invalidPlaceholder(index, previousDataType, newDataType):
            return "Invalid placeholder at index: \(index): would overwrite previous placeholder data type of \(previousDataType) with \(newDataType)"
        case let .unsupportedFormatCharacter(character):
            return "Unsupported format character: \(character)"
        case let .unsupportedFormatSpecifier(formatSpecifier):
            return "Unsupported format specifier: \(formatSpecifier)"
        }
    }
}
