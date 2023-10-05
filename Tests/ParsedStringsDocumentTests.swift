//
//  ParsedStringsDocumentTests.swift
//
//
//  Created by Stephen Anthony on 12/06/2023.
//

import XCTest
@testable import DJAStrings

final class ParsedStringsDocumentTests: XCTestCase {
    private var parsedStringsDocument: ParsedStringsDocument!
    
    override func tearDown() {
        parsedStringsDocument = nil
        super.tearDown()
    }
    
    func testItInitialisesFromAURL() throws {
        try givenAParsedStringsDocument(fromFileNamed: "Simple Localisations")
        XCTAssertEqual(parsedStringsDocument.stringsDocument.strings.count, 9)
        XCTAssertEqual(parsedStringsDocument.tableName, "Simple Localisations")
    }
    
    private func givenAParsedStringsDocument(fromFileNamed filename: String) throws {
        let url = Bundle.module.urls(forResourcesWithExtension: "xcstrings", subdirectory: "XCStrings Files")!.first { $0.lastPathComponent.hasPrefix(filename) }!
        parsedStringsDocument = try ParsedStringsDocument(stringsDocumentURL: url)
    }
}
