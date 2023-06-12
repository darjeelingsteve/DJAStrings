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
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 8)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "Automatically extracted untranslated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "Manually added untranslated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[2], "Plain string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[3], "Stale string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[4], "String with %1$d positional placeholders %2$lu")
        XCTAssertEqual(stringsDocument.orderedStringKeys[5], "String with default value")
        XCTAssertEqual(stringsDocument.orderedStringKeys[6], "String with placeholder %@")
        XCTAssertEqual(stringsDocument.orderedStringKeys[7], "ysn-yz-3Pz.text")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.comment)
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.stringUnit?.value, "Einfache saite")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.stringUnit?.value, "String uni")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.extractionState, .stale)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.stringUnit?.value, "Abgestandene zeichenfolge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.stringUnit?.value, "Chaîne obsolète")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.comment)
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["de"]?.stringUnit?.value, "String mit %1$dpositionsplatzhaltern %2$lu")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["fr"]?.stringUnit?.value, "Chaîne avec %1$d des espaces réservés de position %2$lu")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.extractionState, .extractedWithValue)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["en"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["en"]?.stringUnit?.value, "value")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.comment, "Extracted from NSLocalizedStringWithDefaultValue")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["de"]?.stringUnit?.value, "String mit platzhalter %@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["fr"]?.stringUnit?.state, .needsReview)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["fr"]?.stringUnit?.value, "Chaîne avec espace réservé %@")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.extractionState, .extractedWithValue)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["en"]?.stringUnit?.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["en"]?.stringUnit?.value, "XIB Text")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["fr"]?.stringUnit?.value, "Texte XIB")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.localisations?["de"]?.stringUnit?.value, "XIB Text")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[7]]?.comment, "Class = \"UILabel\"; text = \"XIB Text\"; ObjectID = \"ysn-yz-3Pz\";")
    }
}

// MARK: - Namespace-keyed Localisations

extension XCStringsDocumentTests {
    func testItLoadsANamespacedKeyedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Namespaced-keyed Localisations")
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
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 2)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "You have %1$d messages across %2$d inboxes")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "You have %d new messages")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.stringUnit?.value, "You have %#@message_count@ across %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.value, "no messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.value, "no inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.value, "%arg inbox")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.value, "%arg inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.stringUnit?.value, "Vous avez %#@message_count@ dans %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.value, "pas de messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.value, "pas de boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.value, "%arg boîte de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.value, "%arg boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.stringUnit?.value, "Sie haben %#@message_count@ in %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.value, "keine Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.value, "%arg Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.value, "%arg Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.value, "keine Posteingänge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.value, "%arg Posteingang")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.value, "%arg Posteingänge")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit.value, "You have no new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit.value, "You have %d new message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.plural?.other.stringUnit.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.variations?.plural?.other.stringUnit.value, "You have %d new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit.value, "Vous n'avez pas de nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit.value, "Vous avez %d nouveau message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit.value, "Vous avez %d nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit.value, "Sie haben keine neuen Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit.value, "Sie haben %d neue Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.variations?.plural?.other.stringUnit.value, "Sie haben %d neue Nachrichten")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.comment)
    }
}

// MARK: - Namespace-keyed Pluralised Localisations

extension XCStringsDocumentTests {
    func testItLoadsANamespacedKeyedPluralisedLocalisationsStringsFile() throws {
        try givenAStringsDocument(fromFileNamed: "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(stringsDocument.sourceLanguage, "en")
        XCTAssertEqual(stringsDocument.version, "1.0")
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 2)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "messages.count")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "messages.message_and_inbox_count")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.zero?.stringUnit.value, "You have no new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.one?.stringUnit.value, "You have %d new message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.other.stringUnit.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["en"]?.variations?.plural?.other.stringUnit.value, "You have %d new messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.zero?.stringUnit.value, "Vous n'avez pas de nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.one?.stringUnit.value, "Vous avez %d nouveau message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["fr"]?.variations?.plural?.other.stringUnit.value, "Vous avez %d nouveaux messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.zero?.stringUnit.value, "Sie haben keine neuen Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.one?.stringUnit.value, "Sie haben %d neue Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations?["de"]?.variations?.plural?.other.stringUnit.value, "Sie haben %d neue Nachrichten")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.comment)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.stringUnit?.value, "You have %#@message_count@ across %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.value, "no messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.value, "no inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.value, "%arg inbox")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["en"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.value, "%arg inboxes")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.stringUnit?.value, "Vous avez %#@message_count@ dans %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.value, "pas de messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.value, "%arg message")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.value, "%arg messages")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.value, "pas de boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.value, "%arg boîte de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["fr"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.value, "%arg boîtes de réception")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.stringUnit?.value, "Sie haben %#@message_count@ in %#@inbox_count@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?.count, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.argumentNumber, 1)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.zero?.stringUnit.value, "keine Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.one?.stringUnit.value, "%arg Nachricht")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["message_count"]?.variations.plural?.other.stringUnit.value, "%arg Nachrichten")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.argumentNumber, 2)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.formatSpecifier, "d")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.zero?.stringUnit.value, "keine Posteingänge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.one?.stringUnit.value, "%arg Posteingang")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations?["de"]?.substitutions?["inbox_count"]?.variations.plural?.other.stringUnit.value, "%arg Posteingänge")
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.comment)
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
        case let .variations(variations):
            return variations
        default:
            return nil
        }
    }
    
    var substitutions: [String: Substitution]? {
        switch self {
        case let .stringUnit(_, substitutions):
            return substitutions
        default:
            return nil
        }
    }
}

private extension XCStringsDocument.StringLocalisation.Localisation.Variations {
    var plural: Plural? {
        switch self {
        case let .plural(plural):
            return plural
        }
    }
}
