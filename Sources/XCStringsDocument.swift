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
        strings.keys.sorted(using: .localizedStandard)
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
        indirect enum Localisation: Decodable {
            
            /// The string that will be used in place of the default language
            /// string key, with optional substitutions.
            case stringUnit(_: StringUnit, substitutions: [String: Substitution]?)
            
            /// A localisation that includes variations, with optional
            /// substitutions.
            case variations(_: Variations, substitutions: [String: Substitution]?)
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if let stringUnit = try container.decodeIfPresent(StringUnit.self, forKey: .stringUnit) {
                    self = .stringUnit(stringUnit, substitutions: try container.decodeIfPresent([String: Substitution].self, forKey: .substitutions))
                } else if let variations = try container.decodeIfPresent(Variations.self, forKey: .variations) {
                    self = .variations(variations, substitutions: try container.decodeIfPresent([String: Substitution].self, forKey: .substitutions))
                } else {
                    throw DJAStringsError.unrecognisedLocalisationType
                }
            }
            
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
            
            /// A substitution used when replacing a placeholder in a localised
            /// string.
            struct Substitution: Decodable {
                
                /// The number of the placeholder argument in the localised
                /// string to which this substitution applies.
                let argumentNumber: Int
                
                /// The format specifier applied to the value that will take the
                /// place of this substitution.
                let formatSpecifier: String
                
                /// The variations of the substitution.
                let variations: Variations
                
                private enum CodingKeys: String, CodingKey {
                    case argumentNumber = "argNum"
                    case formatSpecifier
                    case variations
                }
            }
            
            /// The variations of a localisation.
            enum Variations: Decodable {
                
                /// A localisation that varies by pluralisation rules.
                case plural(_: Plural)
                
                /// A localisation that varies by device type.
                case device(_: Device)
                
                /// A localisation that varies by width rules.
                case width(_: [String: Localisation])
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    if let plural = try container.decodeIfPresent(Plural.self, forKey: .plural) {
                        self = .plural(plural)
                    } else if let device = try container.decodeIfPresent(Device.self, forKey: .device) {
                        self = .device(device)
                    } else if let widthVariations = try container.decodeIfPresent([String: Localisation].self, forKey: .width) {
                        self = .width(widthVariations)
                    } else {
                        throw DJAStringsError.unrecognisedVariationType
                    }
                }
                
                /// The different forms that the localisation takes, based on
                /// pluralisation.
                struct Plural: Decodable {
                    
                    /// The variation to use for the "zero" plural category, if
                    /// any.
                    let zero: Localisation?
                    
                    /// The variation to use for the "one" plural category, if
                    /// any.
                    let one: Localisation?
                    
                    /// The variation  to use for the "two" plural category, if
                    /// any.
                    let two: Localisation?
                    
                    /// The variation to use for the "few" plural category, if
                    /// any.
                    let few: Localisation?
                    
                    /// The variation to use for the "many" plural category, if
                    /// any.
                    let many: Localisation?
                    
                    /// The variation to use for the "other" (default) plural
                    /// category.
                    let other: Localisation
                }
                
                /// The different forms that the localisation takes, based on
                /// device.
                struct Device: Decodable {
                    
                    /// The variation to use for the iPhone device, if any.
                    let iPhone: Localisation?
                    
                    /// The variation to use for the iPod device, if any.
                    let iPod: Localisation?
                    
                    /// The variation to use for the iPad device, if any.
                    let iPad: Localisation?
                    
                    /// The variation to use for the Apple Watch device, if any.
                    let appleWatch: Localisation?
                    
                    /// The variation to use for the Apple TV device, if any.
                    let appleTV: Localisation?
                    
                    /// The variation to use for the Mac device, if any.
                    let mac: Localisation?
                    
                    /// The variation to use for Other devices, if any.
                    let other: Localisation?
                    
                    private enum CodingKeys: String, CodingKey {
                        case iPhone = "iphone"
                        case iPod = "ipod"
                        case iPad = "ipad"
                        case appleWatch = "applewatch"
                        case appleTV = "appletv"
                        case mac = "mac"
                        case other = "other"
                    }
                }
                
//                /// An individual string variation.
//                struct Variation: Decodable {
//                    
//                    /// The variation's translation.
//                    let stringUnit: StringUnit
//                    
//                    init(from decoder: Decoder) throws {
//                        let container = try decoder.container(keyedBy: CodingKeys.self)
//                        if let stringUnit = try container.decodeIfPresent(StringUnit.self, forKey: .stringUnit) {
//                            self.stringUnit = stringUnit
//                            return
//                        } else if let variation = try container.decodeIfPresent(Variations.self, forKey: .variations) {
//                            throw XCStringsDocument.ParsingError.unrecognisedVariationType
//                        }
//                        throw XCStringsDocument.ParsingError.unrecognisedVariationType
//                    }
//                    
//                    /// This may need to be removed and a `Localisation` used
//                    /// in its place to support device-varied localisations
//                    /// that are plural varied.
//                    
//                    private enum CodingKeys: CodingKey {
//                        case stringUnit
//                        case variations
//                    }
//                }
                
                private enum CodingKeys: String, CodingKey {
                    case plural
                    case device
                    case width
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case stringUnit
                case substitutions
                case variations
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case extractionState
            case localisations = "localizations"
            case comment
        }
    }
}
