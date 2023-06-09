//
//  XCStringsDocument.swift
//
//
//  Created by Stephen Anthony on 08/06/2023.
//

import Foundation

/// Represents the contents of an `.xcstrings` file.
struct XCStringsDocument: Decodable {
    
    /// The source language of the document.
    let sourceLanguage: String
    
    /// The localised strings contained within the document. Each key in the
    /// dictionary is a localised string key, used to map individual
    /// localisations to their localised variants.
    let strings: [String: StringLocalisation]
    
    /// The `.xcstrings` file version.
    let version: String
    
    /// The keys of the `strings` dictionary, sorted using natural ordering.
    var orderedStringKeys: [String] {
        strings.keys.sorted()
    }
}

// MARK: - Types

extension XCStringsDocument {
    
    /// Represents the localisations for an individual localisable string key.
    struct StringLocalisation: Decodable {
        
        /// The extraction state of the localisation, if any.
        let extractionState: ExtractionState?
        
        /// The individual language localisations, keyed by the language
        /// identifier of the translation language.
        let localisations: [String: Localisation]?
        
        /// The comment associated with the localisation, if any.
        let comment: String?
        
        /// The different extraction states for a string localisation.
        enum ExtractionState: String, Decodable {
            
            /// The string was extracted manually i.e was entered directly in to
            /// the `.xcstrings` file.
            case manual
            
            /// The string was extracted automatically by Xcode from usage of
            /// `NSLocalizedStringWithDefaultValue`, or from a XIB file.
            case extractedWithValue = "extracted_with_value"
            
            /// The string was extracted automatically by Xcode, but has since
            /// been modified in the location from which it was extracted.
            case stale
        }
        
        /// The localised (translated) variant of the localisable string for a
        /// particular language.
        struct Localisation: Decodable {
            
            /// The string that will be used in place of the default language
            /// string key.
            let stringUnit: StringUnit
            
            /// The localised string translation for a particular language.
            struct StringUnit: Decodable {
                
                /// The state of the translation.
                let state: State
                
                /// The translated value of the localisable string.
                let value: String
                
                /// The different states that a localisation can be in.
                enum State: String, Decodable {
                    
                    /// The translation has just been added to the `.xcstrings`
                    /// file.
                    case new
                    
                    /// The localisation has been successfully translated.
                    case translated
                    
                    /// The current translation has been marked as requiring
                    /// review.
                    case needsReview = "needs_review"
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case extractionState
            case localisations = "localizations"
            case comment
        }
    }
}
