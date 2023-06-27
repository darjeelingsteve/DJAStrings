//
//  Errors.swift
//
//
//  Created by Stephen Anthony on 27/06/2023.
//

import Foundation

enum DJAStringError: Error, LocalizedError {
    case invalidTopLevelLocalisationNameapace(_ topLevelLocalisationNamespace: String)
    
    var errorDescription: String? {
        switch self {
        case let .invalidTopLevelLocalisationNameapace(topLevelLocalisationNamespace):
            return "Invalid top-level localisation namespace: \"\(topLevelLocalisationNamespace)\". The top level namespace must only contain alphanumerics."
        }
    }
}

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

extension XCStringsDocument {
    enum ParsingError: Error {
        case unrecognisedLocalisationType
        case unrecognisedVariationType
    }
}
