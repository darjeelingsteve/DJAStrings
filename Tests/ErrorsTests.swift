//
//  ErrorsTests.swift
//
//
//  Created by Stephen Anthony on 27/06/2023.
//

import XCTest
@testable import DJAStrings

final class ErrorsTests: XCTestCase {
    private var error: DJAStringsError!
    private var vendedLocalizedDescription: String!
    
    override func tearDown() {
        error = nil
        vendedLocalizedDescription = nil
        super.tearDown()
    }
    
    func testItVendsTheCorrectLocalizedDescriptionForTheInvalidTopLevelLocalisationNamespaceError() {
        givenAnError(.invalidTopLevelLocalisationNamespace("Invalid"))
        whenTheErrorLocalizedDescriptionIsVended()
        XCTAssertEqual(vendedLocalizedDescription, "Invalid top-level localisation namespace: \"Invalid\". The top level namespace must only contain alphanumerics.")
    }
    
    func testItVendsTheCorrectLocalizedDescriptionForTheUnrecognisedLocalisationTypeError() {
        givenAnError(.unrecognisedLocalisationType)
        whenTheErrorLocalizedDescriptionIsVended()
        XCTAssertEqual(vendedLocalizedDescription, "Unrecognised localisation type")
    }
    
    func testItVendsTheCorrectLocalizedDescriptionForTheUnrecognisedVariationTypeError() {
        givenAnError(.unrecognisedVariationType)
        whenTheErrorLocalizedDescriptionIsVended()
        XCTAssertEqual(vendedLocalizedDescription, "Unrecognised localisation variation type")
    }
    
    func testItVendsTheCorrectLocalizedDescriptionForTheInvalidPlaceholderError() {
        givenAnError(.invalidPlaceholder(index: 4, previousDataType: .float, newDataType: .object))
        whenTheErrorLocalizedDescriptionIsVended()
        XCTAssertEqual(vendedLocalizedDescription, "Invalid placeholder at index: 4: would overwrite previous placeholder data type of float with object")
    }
    
    func testItVendsTheCorrectLocalizedDescriptionForTheUnsupportedFormatCharacterError() {
        givenAnError(.unsupportedFormatCharacter("Z"))
        whenTheErrorLocalizedDescriptionIsVended()
        XCTAssertEqual(vendedLocalizedDescription, "Unsupported format character: Z")
    }
    
    func testItVendsTheCorrectLocalizedDescriptionForTheUnsupportedFormatSpecifierError() {
        givenAnError(.unsupportedFormatSpecifier("%%%%%"))
        whenTheErrorLocalizedDescriptionIsVended()
        XCTAssertEqual(vendedLocalizedDescription, "Unsupported format specifier: %%%%%")
    }
    
    private func givenAnError(_ error: DJAStringsError) {
        self.error = error
    }
    
    private func whenTheErrorLocalizedDescriptionIsVended() {
        vendedLocalizedDescription = error.localizedDescription
    }
}
