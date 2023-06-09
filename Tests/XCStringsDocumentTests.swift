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
        
        XCTAssertEqual(stringsDocument.orderedStringKeys.count, 7)
        XCTAssertEqual(stringsDocument.orderedStringKeys[0], "Automatically extracted untranslated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[1], "Manually added untranslated string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[2], "Plain string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[3], "Stale string")
        XCTAssertEqual(stringsDocument.orderedStringKeys[4], "String with %1$d positional placeholders %2$lu")
        XCTAssertEqual(stringsDocument.orderedStringKeys[5], "String with default value")
        XCTAssertEqual(stringsDocument.orderedStringKeys[6], "String with placeholder %@")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.extractionState)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[0]]?.localisations)
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.extractionState, .manual)
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[1]]?.localisations)
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["de"]?.stringUnit.value, "Einfache saite")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[2]]?.localisations?["fr"]?.stringUnit.value, "String uni")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.extractionState, .stale)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["de"]?.stringUnit.value, "Abgestandene zeichenfolge")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[3]]?.localisations?["fr"]?.stringUnit.value, "Chaîne obsolète")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["de"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["de"]?.stringUnit.value, "String mit %1$dpositionsplatzhaltern %2$lu")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["fr"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[4]]?.localisations?["fr"]?.stringUnit.value, "Chaîne avec %1$d des espaces réservés de position %2$lu")
        
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.extractionState, .extractedWithValue)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["en"]?.stringUnit.state, .new)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[5]]?.localisations?["en"]?.stringUnit.value, "value")
        
        XCTAssertNil(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.extractionState)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["de"]?.stringUnit.state, .translated)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["de"]?.stringUnit.value, "String mit platzhalter %@")
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["fr"]?.stringUnit.state, .needsReview)
        XCTAssertEqual(stringsDocument.strings[stringsDocument.orderedStringKeys[6]]?.localisations?["fr"]?.stringUnit.value, "Chaîne avec espace réservé %@")
    }
}
