//
//  ParsedStringsDocument.swift
//
//
//  Created by Stephen Anthony on 12/06/2023.
//

import Foundation

/// Parses an `.xcstrings` document from a given URL.
struct ParsedStringsDocument {
    
    /// The URL from which the document was parsed.
    let originURL: URL
    
    /// The parsed strings document.
    let stringsDocument: XCStringsDocument
    
    /// The name of the table in which `stringsDocument`'s string keys are
    /// found.
    var tableName: String {
        (originURL.lastPathComponent as NSString).deletingPathExtension
    }
    
    /// Creates a new parsed strings document using the given URL as the origin
    /// of the `.xcstrings` file to be parsed.
    /// - Parameter stringsDocumentURL: The URL at which the `.xcstrings` file
    /// being parsed can be found.
    init(stringsDocumentURL: URL) throws {
        originURL = stringsDocumentURL
        stringsDocument = try JSONDecoder().decode(XCStringsDocument.self, from: Data(contentsOf: stringsDocumentURL))
    }
}
