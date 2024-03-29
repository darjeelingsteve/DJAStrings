//
//  XCStringsDocumentTests.swift
//
//
//  Created by Stephen Anthony on 08/06/2023.
//

import XCTest
@testable import DJAStrings

final class XCStringsDocumentTests: XCTestCase {
    private var stringsDocument: XCStringsDocument!
    
    override func tearDown() {
        stringsDocument = nil
        super.tearDown()
    }
    
    private func givenAStringsDocument(fromFileNamed filename: String) throws {
        let url = Bundle.module.urls(forResourcesWithExtension: "xcstrings", subdirectory: "XCStrings Files")!.first { $0.lastPathComponent.hasPrefix(filename) }!
        stringsDocument = try JSONDecoder().decode(XCStringsDocument.self, from: Data(contentsOf: url))
    }
}

// MARK: - Simple Localisations

extension XCStringsDocumentTests {
    func testItLoadsASimpleLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Simple Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 9)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "Automatically extracted untranslated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "Manually added untranslated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[2], "Migrated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[3], "Plain string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[4], "Stale string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[5], "String with %1$d positional placeholders %2$lu")
        XCTAssertEqual(stringsDocument.orderedStringKeys[6], "String with default value")
        XCTAssertEqual(stringsDocument.orderedStringKeys[7], "String with placeholder %@")
        XCTAssertEqual(stringsDocument.orderedStringKeys[8], "ysn-yz-3Pz.text")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.extractionState, .migrated)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.comment)
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.stringUnit?.value, "Einfache saite")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.stringUnit?.value, "String uni")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.extractionState, .stale)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["de"]?.stringUnit?.value, "Abgestandene zeichenfolge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["fr"]?.stringUnit?.value, "Chaîne obsolète")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.comment)
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["de"]?.stringUnit?.value, "String mit %1$dpositionsplatzhaltern %2$lu")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["fr"]?.stringUnit?.value, "Chaîne avec %1$d des espaces réservés de position %2$lu")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.extractionState, .extractedWithValue)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["en"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["en"]?.stringUnit?.value, "value")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.comment, "Extracted from NSLocalizedStringWithDefaultValue")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["de"]?.stringUnit?.value, "String mit platzhalter %@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["fr"]?.stringUnit?.state, .needsReview)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["fr"]?.stringUnit?.value, "Chaîne avec espace réservé %@")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.extractionState, .extractedWithValue)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.localisations?["en"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.localisations?["en"]?.stringUnit?.value, "XIB Text")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.localisations?["fr"]?.stringUnit?.value, "Texte XIB")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.localisations?["de"]?.stringUnit?.value, "XIB Text")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[8]]?.comment, "Class = \"UILabel\"; text = \"XIB Text\"; ObjectID = \"ysn-yz-3Pz\";")
    }
}

// MARK: - Namespace-keyed Localisations

extension XCStringsDocumentTests {
    func testItLoadsANamespaceKeyedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Namespace-keyed Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 2)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "screen.footer_welcome")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "screen.title")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.stringUnit?.value, "Welcome, %@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.stringUnit?.value, "Bienvenue, %@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.stringUnit?.value, "Willkommen, %@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment, "Main screen footer")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.value, "Home")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.value, "Accueil")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.value, "Startseite")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.comment, "Main screen title")
    }
}

// MARK: - Pluralised Localisations

extension XCStringsDocumentTests {
    func testItLoadsAPluralisedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Pluralised Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 4)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "Localisation with plural variation in %d language")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "WholeStringSubstitutions")
        XCTAssertEqual(stringsDocument.orderedStringKeys[2], "You have %1$d messages across %2$d inboxes")
        XCTAssertEqual(stringsDocument.orderedStringKeys[3], "You have %d new messages")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit?.value, "Lokalisierung mit Pluralvariation in %d Sprache")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.other.stringUnit?.value, "Lokalisierung mit Pluralvariation in %d Sprachen")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.value, "%#@keycount@%#@tablecount@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?.count, 2)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.argumentNumber)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.variations.plural?.zero?.stringUnit?.value, "No key")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.variations.plural?.one?.stringUnit?.value, "One key")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["keycount"]?.variations.plural?.other.stringUnit?.value, "Keys")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.argumentNumber)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.variations.plural?.zero?.stringUnit?.value, "No table")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.variations.plural?.one?.stringUnit?.value, "One table")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["tablecount"]?.variations.plural?.other.stringUnit?.value, "Tables")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.value, "%#@keycount@%#@tablecount@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?.count, 2)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.argumentNumber)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.variations.plural?.zero?.stringUnit?.value, "Pas de clé")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.variations.plural?.one?.stringUnit?.value, "Une clé")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["keycount"]?.variations.plural?.other.stringUnit?.value, "Clés")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.argumentNumber)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.variations.plural?.zero?.stringUnit?.value, "Pas de tableau")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.variations.plural?.one?.stringUnit?.value, "Une table")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["tablecount"]?.variations.plural?.other.stringUnit?.value, "Les tables")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.value, "%#@keycount@%#@tablecount@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?.count, 2)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.argumentNumber)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.variations.plural?.zero?.stringUnit?.value, "Kein Schlüssel")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.variations.plural?.one?.stringUnit?.value, "Ein Schlüssel")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["keycount"]?.variations.plural?.other.stringUnit?.value, "Schlüssel")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.argumentNumber)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.variations.plural?.zero?.stringUnit?.value, "Kein Tisch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.variations.plural?.one?.stringUnit?.value, "Ein Tisch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["tablecount"]?.variations.plural?.other.stringUnit?.value, "Tische")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.stringUnit?.value, "You have %#@message_count@ across %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.value, "no messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.value, "no inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.value, "%arg inbox")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.value, "%arg inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.stringUnit?.value, "Vous avez %#@message_count@ dans %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.value, "pas de messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.value, "pas de boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.value, "%arg boîte de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.value, "%arg boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.stringUnit?.value, "Sie haben %#@message_count@ in %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.value, "keine Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.value, "%arg Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.value, "%arg Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.value, "keine Posteingänge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.value, "%arg Posteingang")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.value, "%arg Posteingänge")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit?.value, "You have no new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit?.value, "You have %d new message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.plural?.other.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.plural?.other.stringUnit?.value, "You have %d new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit?.value, "Vous n'avez pas de nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit?.value, "Vous avez %d nouveau message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit?.value, "Vous avez %d nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit?.value, "Sie haben keine neuen Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit?.value, "Sie haben %d neue Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.variations?.plural?.other.stringUnit?.value, "Sie haben %d neue Nachrichten")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.comment)
    }
}

// MARK: - Namespace-keyed Pluralised Localisations

extension XCStringsDocumentTests {
    func testItLoadsANamespaceKeyedPluralisedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 2)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "messages.count")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "messages.message_and_inbox_count")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit?.value, "You have no new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit?.value, "You have %d new message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.other.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.other.stringUnit?.value, "You have %d new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit?.value, "Vous n'avez pas de nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit?.value, "Vous avez %d nouveau message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit?.value, "Vous avez %d nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit?.value, "Sie haben keine neuen Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit?.value, "Sie haben %d neue Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.other.stringUnit?.value, "Sie haben %d neue Nachrichten")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.value, "You have %#@message_count@ across %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.value, "no messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.value, "no inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.value, "%arg inbox")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.value, "%arg inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.value, "Vous avez %#@message_count@ dans %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.value, "pas de messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.value, "pas de boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.value, "%arg boîte de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.value, "%arg boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.value, "Sie haben %#@message_count@ in %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit?.value, "keine Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit?.value, "%arg Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit?.value, "%arg Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit?.value, "keine Posteingänge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit?.value, "%arg Posteingang")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit?.value, "%arg Posteingänge")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.comment)
    }
}

// MARK: - Device-varied Localisations

extension XCStringsDocumentTests {
    func testItLoadsADeviceVariedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Device-varied Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 1)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "Tap your device")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.iPhone?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.iPhone?.stringUnit?.value, "Tap your iPhone")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.iPod?.stringUnit?.value, "Tap your iPod")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.iPad?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.iPad?.stringUnit?.value, "Tap your iPad")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.appleWatch?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.appleWatch?.stringUnit?.value, "Tap your Apple Watch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.appleTV?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.appleTV?.stringUnit?.value, "Click your Apple TV")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.mac?.stringUnit?.value, "Click your Mac")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.appleVision?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.appleVision?.stringUnit?.value, "Tap your Apple Vision")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.value, "Tap your device")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.iPhone?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.iPhone?.stringUnit?.value, "Appuyez sur votre iPhone")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.iPod?.stringUnit?.value, "Appuyez sur votre iPod")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.iPad?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.iPad?.stringUnit?.value, "Appuyez sur votre iPad")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.appleWatch?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.appleWatch?.stringUnit?.value, "Appuyez sur votre Apple Watch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.appleTV?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.appleTV?.stringUnit?.value, "Cliquez sur votre Apple TV")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.mac?.stringUnit?.value, "Cliquez sur votre Mac")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.appleVision?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.appleVision?.stringUnit?.value, "Appuyez sur votre Apple Vision")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.value, "Appuyez sur votre appareil")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.iPhone?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.iPhone?.stringUnit?.value, "Tippen Sie auf Ihr iPhone")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.iPod?.stringUnit?.value, "Tippen Sie auf Ihr iPod")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.iPad?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.iPad?.stringUnit?.value, "Tippen Sie auf Ihr iPad")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.appleWatch?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.appleWatch?.stringUnit?.value, "Tippen Sie auf Ihr Apple Watch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.appleTV?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.appleTV?.stringUnit?.value, "Klicken Sie auf Ihr Apple TV")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.mac?.stringUnit?.value, "Klicken Sie auf Ihr Mac")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.appleVision?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.appleVision?.stringUnit?.value, "Tippen Sie auf Ihr Apple Vision")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.value, "Tippen Sie auf Ihr Gerät")
    }
    
    func testItLoadsANamespaceKeyedDeviceVariedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Namespace-keyed Device-varied Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 3)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "device.messages_and_inbox_count.cta")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "device.messages.cta")
        XCTAssertEqual(stringsDocument.orderedStringKeys[2], "device.tap")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.mac?.stringUnit?.value, "Click to view your %#@message_count@ in %#@inbox_count@.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.value, "Tap to view your %#@message_count@ in %#@inbox_count@.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.mac?.stringUnit?.value, "Cliquez pour afficher %#@message_count@ dans %#@inbox_count@.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.value, "Appuyez pour afficher %#@message_count@ dans %#@inbox_count@.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.mac?.stringUnit?.value, "Klicken Sie hier, um Ihre %#@message_count@ in %#@inbox_count@.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.value, "Tippen Sie hier, um Ihre %#@message_count@ in %#@inbox_count@.")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.device?.iPod?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.device?.iPod?.variations?.plural?.one?.stringUnit?.value, "Tap to view your %d message.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.device?.iPod?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.device?.iPod?.variations?.plural?.other.stringUnit?.value, "Tap to view your %d messages.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.value, "Tap to view your %d messages.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.device?.iPod?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.device?.iPod?.variations?.plural?.one?.stringUnit?.value, "Appuyez pour afficher votre %d message.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.device?.iPod?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.device?.iPod?.variations?.plural?.other.stringUnit?.value, "Appuyez pour afficher vos %d messages.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.value, "Appuyez pour afficher vos %d messages.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.device?.iPod?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.device?.iPod?.variations?.plural?.one?.stringUnit?.value, "Tippen Sie hier, um Ihre %d-Nachricht anzuzeigen.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.device?.iPod?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.device?.iPod?.variations?.plural?.other.stringUnit?.value, "Tippen Sie hier, um Ihre %d Nachrichten anzuzeigen.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.value, "Tippen Sie hier, um Ihre %d Nachrichten anzuzeigen.")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.iPhone?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.iPhone?.stringUnit?.value, "Tap your iPhone")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.iPod?.stringUnit?.value, "Tap your iPod")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.iPad?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.iPad?.stringUnit?.value, "Tap your iPad")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.appleWatch?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.appleWatch?.stringUnit?.value, "Tap your Apple Watch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.appleTV?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.appleTV?.stringUnit?.value, "Click your Apple TV")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.mac?.stringUnit?.value, "Click your Mac")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.appleVision?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.appleVision?.stringUnit?.value, "Tap your Apple Vision")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.device?.other?.stringUnit?.value, "Tap your device")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.iPhone?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.iPhone?.stringUnit?.value, "Appuyez sur votre iPhone")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.iPod?.stringUnit?.value, "Appuyez sur votre iPod")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.iPad?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.iPad?.stringUnit?.value, "Appuyez sur votre iPad")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.appleWatch?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.appleWatch?.stringUnit?.value, "Appuyez sur votre Apple Watch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.appleTV?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.appleTV?.stringUnit?.value, "Cliquez sur votre Apple TV")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.mac?.stringUnit?.value, "Cliquez sur votre Mac")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.appleVision?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.appleVision?.stringUnit?.value, "Appuyez sur votre Apple Vision")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.variations?.device?.other?.stringUnit?.value, "Appuyez sur votre appareil")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.iPhone?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.iPhone?.stringUnit?.value, "Tippen Sie auf Ihr iPhone")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.iPod?.stringUnit?.value, "Tippen Sie auf Ihr iPod")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.iPad?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.iPad?.stringUnit?.value, "Tippen Sie auf Ihr iPad")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.appleWatch?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.appleWatch?.stringUnit?.value, "Tippen Sie auf Ihr Apple Watch")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.appleTV?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.appleTV?.stringUnit?.value, "Klicken Sie auf Ihr Apple TV")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.mac?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.mac?.stringUnit?.value, "Klicken Sie auf Ihr Mac")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.appleVision?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.appleVision?.stringUnit?.value, "Tippen Sie auf Ihr Apple Vision")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.variations?.device?.other?.stringUnit?.value, "Tippen Sie auf Ihr Gerät")
    }
}

// MARK: - Variable-width Localisations

extension XCStringsDocumentTests {
    func testItLoadsAVariableWidthLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Variable-width Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 5)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "greetings_message")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "message_count")
        XCTAssertEqual(stringsDocument.orderedStringKeys[2], "width_varied_by_device")
        XCTAssertEqual(stringsDocument.orderedStringKeys[3], "width_varied_by_plural")
        XCTAssertEqual(stringsDocument.orderedStringKeys[4], "width_varied_by_plural_and_device")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?.count, 3)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?["1"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?["1"]?.stringUnit?.value, "Hi!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?["20"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?["20"]?.stringUnit?.value, "Hello!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?["70"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.width?["70"]?.stringUnit?.value, "Greetings and Salutations!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?.count, 3)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?["1"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?["1"]?.stringUnit?.value, "Salut!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?["20"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?["20"]?.stringUnit?.value, "Bonjour!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?["70"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.width?["70"]?.stringUnit?.value, "Salutations et Salutations!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?.count, 3)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?["1"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?["1"]?.stringUnit?.value, "Hallo!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?["20"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?["20"]?.stringUnit?.value, "Hallo!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?["70"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.width?["70"]?.stringUnit?.value, "Grüße und Begrüßungen!")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.width?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.width?["20"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.width?["20"]?.stringUnit?.value, "%#@message_count_20@ in %#@inbox_count_20@.")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.variations.plural?.zero?.stringUnit?.value, "No msgs")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.variations.plural?.one?.stringUnit?.value, "%arg msg")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_20"]?.variations.plural?.other.stringUnit?.value, "%arg msgs")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.variations.plural?.zero?.stringUnit?.value, "no boxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.variations.plural?.one?.stringUnit?.value, "%arg box")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_20"]?.variations.plural?.other.stringUnit?.value, "%arg boxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.variations.plural?.zero?.stringUnit?.value, "no messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.variations.plural?.one?.stringUnit?.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count_70"]?.variations.plural?.other.stringUnit?.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.variations.plural?.zero?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.variations.plural?.zero?.stringUnit?.value, "no inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.variations.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.variations.plural?.one?.stringUnit?.value, "%arg inbox")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.variations.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count_70"]?.variations.plural?.other.stringUnit?.value, "%arg inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.width?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.width?["20"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.width?["20"]?.stringUnit?.value, "")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.width?["70"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.width?["70"]?.stringUnit?.value, "")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.width?["20"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.width?["20"]?.stringUnit?.value, "")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.width?["70"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.width?["70"]?.stringUnit?.value, "")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.iPod?.stringUnit?.value, "Hello iPod!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.other?.stringUnit?.value, "Hello!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.iPod?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.iPod?.stringUnit?.value, "Greetings and Salutations iPod!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.other?.stringUnit?.value, "Greetings and Salutations!")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.plural?.one?.stringUnit?.value, "Hello %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.plural?.other.stringUnit?.value, "Hellos %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.plural?.one?.stringUnit?.value, "Greetings and Salutation %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.plural?.other.stringUnit?.value, "Greetings and Salutations %d!")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.iPhone?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.iPhone?.variations?.plural?.one?.stringUnit?.value, "Hello iPhone %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.iPhone?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.iPhone?.variations?.plural?.other.stringUnit?.value, "Hellos iPhone %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["20"]?.variations?.device?.other?.stringUnit?.value, "Hello Other Device %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.appleWatch?.variations?.plural?.one?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.appleWatch?.variations?.plural?.one?.stringUnit?.value, "Greetings and Salutation Apple Watch %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.appleWatch?.variations?.plural?.other.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.appleWatch?.variations?.plural?.other.stringUnit?.value, "Greetings and Salutations Apple Watch %d!")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.other?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["en"]?.variations?.width?["70"]?.variations?.device?.other?.stringUnit?.value, "Greetings and Salutations Other Device %d!")
    }
}

private extension XCStringsDocument.StringLocalisation.Localisation {
    var stringUnit: StringUnit? {
        switch self {
        case let .stringUnit(stringUnit, _):
            return stringUnit
        default:
            return nil
        }
    }
    
    var variations: Variations? {
        switch self {
        case let .variations(variations, _):
            return variations
        default:
            return nil
        }
    }
    
    var substitutions: [String: Substitution]? {
        switch self {
        case let .stringUnit(_, substitutions):
            return substitutions
        case let .variations(_, substitutions):
            return substitutions
        }
    }
}

private extension XCStringsDocument.StringLocalisation.Localisation.Variations {
    var plural: Plural? {
        switch self {
        case let .plural(plural):
            return plural
        default:
            return nil
        }
    }
    
    var device: Device? {
        switch self {
        case let .device(device):
            return device
        default:
            return nil
        }
    }
    
    var width: [String: XCStringsDocument.StringLocalisation.Localisation]? {
        switch self {
        case let .width(widthVariations):
            return widthVariations
        default:
            return nil
        }
    }
}
