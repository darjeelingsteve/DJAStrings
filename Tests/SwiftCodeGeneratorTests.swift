//
//  SwiftCodeGeneratorTests.swift
//
//
//  Created by Stephen Anthony on 14/06/2023.
//

import XCTest
@testable import DJAStrings

final class SwiftCodeGeneratorTests: XCTestCase {
    private var swiftCodeGenerator: SwiftCodeGenerator!
    private var vendedSwiftCode: String!
    
    override func tearDown() {
        swiftCodeGenerator = nil
        super.tearDown()
    }
    
    private func givenASwiftCodeGenerator(withRootLocalisationsTreeNode rootLocalisationsTreeNode: LocalisationsTreeNode, resourceBundleLocationKind: ResourceBundleLocationKind = .standard, formattingConfigurationFileURL: URL? = nil) {
        swiftCodeGenerator = SwiftCodeGenerator(rootLocalisationsTreeNode: rootLocalisationsTreeNode,
                                                resourceBundleLocationKind: resourceBundleLocationKind,
                                                formattingConfigurationFileURL: formattingConfigurationFileURL)
    }
    
    private func whenSwiftCodeIsVended() throws {
        vendedSwiftCode = try swiftCodeGenerator.swiftSource
    }
}

// MARK: - Enum Generation

extension SwiftCodeGeneratorTests {
    func testItProducesTheCorrectOutputForASingleNodeWithOneLocalisation() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForASingleNodeWithMultipleLocalisations() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised One")
                                                                                            ]),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised Two")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised One
    static let localisationOne = DJALocalizedString("localisation_one", tableName: "Localizable", comment: "")

    /// Localised Two
    static let localisationTwo = DJALocalizedString("localisation_two", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForASingleNodeWithMultipleChildNodes() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [],
                                                                                          childNodes: [
                                                                                            TestLocalisationsTreeNode(name: "child_one",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: []),
                                                                                            TestLocalisationsTreeNode(name: "child_two",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_two.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_two.two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: "message_count", type: .integer)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: [
                                                                                                                        TestLocalisationsTreeNode(name: "nested_child",
                                                                                                                                                  localisations: [
                                                                                                                                                    Localisation(key: "child_two.nested_child.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                                                                        Localisation.Preview(description: nil, value: "Child Two Nested One")
                                                                                                                                                    ])
                                                                                                                                                  ],
                                                                                                                                                  childNodes: [])
                                                                                                                      ])
                                                                                          ]))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    public enum ChildOne {
        /// Child One One
        static let one = DJALocalizedString("child_one.one", tableName: "Localizable", comment: "")

        /// Child One Two
        static func two(_ p0: CustomStringConvertible) -> Swift.String {
            Swift.String.localizedStringWithFormat(DJALocalizedString("child_one.two", tableName: "Localizable", comment: ""), p0.description)
        }
    }

    public enum ChildTwo {
        /// Child Two One
        static let one = DJALocalizedString("child_two.one", tableName: "Localizable", comment: "")

        /// Child Two Two
        static func two(messageCount: Int) -> Swift.String {
            Swift.String.localizedStringWithFormat(DJALocalizedString("child_two.two", tableName: "Localizable", comment: ""), messageCount)
        }

        public enum NestedChild {
            /// Child Two Nested One
            static let one = DJALocalizedString("child_two.nested_child.one", tableName: "Localizable", comment: "")
        }
    }
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForASingleNodeWithMultipleLocalisationsAndMultipleChildNodes() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localisation One")
                                                                                            ]),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localisation Two")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: [
                                                                                            TestLocalisationsTreeNode(name: "child_one",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: []),
                                                                                            TestLocalisationsTreeNode(name: "child_two",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_two.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_two.two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: "message_count", type: .integer)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: [
                                                                                                                        TestLocalisationsTreeNode(name: "nested_child",
                                                                                                                                                  localisations: [
                                                                                                                                                    Localisation(key: "child_two.nested_child.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                                                                        Localisation.Preview(description: nil, value: "Child Two Nested One")
                                                                                                                                                    ])
                                                                                                                                                  ],
                                                                                                                                                  childNodes: [])
                                                                                                                      ])
                                                                                          ]))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localisation One
    static let localisationOne = DJALocalizedString("localisation_one", tableName: "Localizable", comment: "")

    /// Localisation Two
    static let localisationTwo = DJALocalizedString("localisation_two", tableName: "Localizable", comment: "")

    public enum ChildOne {
        /// Child One One
        static let one = DJALocalizedString("child_one.one", tableName: "Localizable", comment: "")

        /// Child One Two
        static func two(_ p0: CustomStringConvertible) -> Swift.String {
            Swift.String.localizedStringWithFormat(DJALocalizedString("child_one.two", tableName: "Localizable", comment: ""), p0.description)
        }
    }

    public enum ChildTwo {
        /// Child Two One
        static let one = DJALocalizedString("child_two.one", tableName: "Localizable", comment: "")

        /// Child Two Two
        static func two(messageCount: Int) -> Swift.String {
            Swift.String.localizedStringWithFormat(DJALocalizedString("child_two.two", tableName: "Localizable", comment: ""), messageCount)
        }

        public enum NestedChild {
            /// Child Two Nested One
            static let one = DJALocalizedString("child_two.nested_child.one", tableName: "Localizable", comment: "")
        }
    }
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForDeeplyNestedChildNodes() throws {
        let childThree = TestLocalisationsTreeNode(name: "child_three", localisations: [Localisation(key: "child_one.child_two.child_three.one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [Localisation.Preview(description: nil, value: "Child Three")])], childNodes: [])
        let childTwo = TestLocalisationsTreeNode(name: "child_two", localisations: [], childNodes: [childThree])
        let childOne = TestLocalisationsTreeNode(name: "child_one", localisations: [], childNodes: [childTwo])
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [],
                                                                                          childNodes: [
                                                                                            childOne
                                                                                          ]))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    public enum ChildOne {
        public enum ChildTwo {
            public enum ChildThree {
                /// Child Three
                static let one = DJALocalizedString("child_one.child_two.child_three.one", tableName: "Localizable", comment: "")
            }
        }
    }
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectFunctionParameterTypesForAllSupportedFormatSpecifiers() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "custom_string_convertible", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Custom String Convertible")
                                                                                            ]),
                                                                                            Localisation(key: "float", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .float)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Float")
                                                                                            ]),
                                                                                            Localisation(key: "integer", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .integer)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Integer")
                                                                                            ]),
                                                                                            Localisation(key: "unsigned_integer", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .unsignedInteger)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Unsigned Integer")
                                                                                            ]),
                                                                                            Localisation(key: "char", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .char)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Char")
                                                                                            ]),
                                                                                            Localisation(key: "c_string", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .cString)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "C String")
                                                                                            ]),
                                                                                            Localisation(key: "pointer", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .pointer)], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Pointer")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// C String
    static func cString(_ p0: UnsafePointer<CChar>) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("c_string", tableName: "Localizable", comment: ""), p0)
    }

    /// Char
    static func char(_ p0: CChar) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("char", tableName: "Localizable", comment: ""), p0)
    }

    /// Custom String Convertible
    static func customStringConvertible(_ p0: CustomStringConvertible) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("custom_string_convertible", tableName: "Localizable", comment: ""), p0.description)
    }

    /// Float
    static func float(_ p0: Double) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("float", tableName: "Localizable", comment: ""), p0)
    }

    /// Integer
    static func integer(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("integer", tableName: "Localizable", comment: ""), p0)
    }

    /// Pointer
    static func pointer(_ p0: UnsafeRawPointer) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("pointer", tableName: "Localizable", comment: ""), p0)
    }

    /// Unsigned Integer
    static func unsignedInteger(_ p0: UInt) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("unsigned_integer", tableName: "Localizable", comment: ""), p0)
    }
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForKeysContainingDashes() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "key-with-dashes", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "key-with-dashes")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// key-with-dashes
    static let keyWithDashes = DJALocalizedString("key-with-dashes", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForKeysContainingEMDashes() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "key—with—em—dashes", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "key—with—em—dashes")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// key—with—em—dashes
    static let keyWithEmDashes = DJALocalizedString("key—with—em—dashes", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForKeysContainingSpaces() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "key with  spaces", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "key with  spaces")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// key with  spaces
    static let keyWithSpaces = DJALocalizedString("key with  spaces", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForWhenLoadingStringsFromASwiftPackageResourceBundle() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []),
                                 resourceBundleLocationKind: .swiftPackage)
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "")
}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle.module, value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

// MARK: - Swift Keywords

extension SwiftCodeGeneratorTests {
    func testItProducesTheCorrectOutputForLocalisationsWithSwiftKeywordNames() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            "as",
                                                                                            "associatedtype",
                                                                                            "break",
                                                                                            "case",
                                                                                            "catch",
                                                                                            "class",
                                                                                            "continue",
                                                                                            "default",
                                                                                            "defer",
                                                                                            "deinit",
                                                                                            "do",
                                                                                            "else",
                                                                                            "enum",
                                                                                            "extension",
                                                                                            "fallthrough",
                                                                                            "false",
                                                                                            "fileprivate",
                                                                                            "for",
                                                                                            "func",
                                                                                            "guard",
                                                                                            "if",
                                                                                            "import",
                                                                                            "in",
                                                                                            "init",
                                                                                            "inout",
                                                                                            "internal",
                                                                                            "is",
                                                                                            "let",
                                                                                            "nil",
                                                                                            "open",
                                                                                            "operator",
                                                                                            "precedencegroup",
                                                                                            "private",
                                                                                            "protocol",
                                                                                            "public",
                                                                                            "repeat",
                                                                                            "rethrows",
                                                                                            "return",
                                                                                            "self",
                                                                                            "Self",
                                                                                            "static",
                                                                                            "struct",
                                                                                            "subscript",
                                                                                            "super",
                                                                                            "switch",
                                                                                            "throw",
                                                                                            "throws",
                                                                                            "true",
                                                                                            "try",
                                                                                            "typealias",
                                                                                            "var",
                                                                                            "where",
                                                                                            "while"
                                                                                          ].flatMap {
                                                                                              plainAndPlaceholderLocalisations(forLocalisationWithKey: $0)
                                                                                          },
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Self
    static let `self` = DJALocalizedString("Self", tableName: "Localizable", comment: "")

    /// Self
    static func `self`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("Self", tableName: "Localizable", comment: ""), p0)
    }

    /// as
    static let `as` = DJALocalizedString("as", tableName: "Localizable", comment: "")

    /// as
    static func `as`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("as", tableName: "Localizable", comment: ""), p0)
    }

    /// associatedtype
    static let `associatedtype` = DJALocalizedString("associatedtype", tableName: "Localizable", comment: "")

    /// associatedtype
    static func `associatedtype`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("associatedtype", tableName: "Localizable", comment: ""), p0)
    }

    /// break
    static let `break` = DJALocalizedString("break", tableName: "Localizable", comment: "")

    /// break
    static func `break`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("break", tableName: "Localizable", comment: ""), p0)
    }

    /// case
    static let `case` = DJALocalizedString("case", tableName: "Localizable", comment: "")

    /// case
    static func `case`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("case", tableName: "Localizable", comment: ""), p0)
    }

    /// catch
    static let `catch` = DJALocalizedString("catch", tableName: "Localizable", comment: "")

    /// catch
    static func `catch`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("catch", tableName: "Localizable", comment: ""), p0)
    }

    /// class
    static let `class` = DJALocalizedString("class", tableName: "Localizable", comment: "")

    /// class
    static func `class`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("class", tableName: "Localizable", comment: ""), p0)
    }

    /// continue
    static let `continue` = DJALocalizedString("continue", tableName: "Localizable", comment: "")

    /// continue
    static func `continue`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("continue", tableName: "Localizable", comment: ""), p0)
    }

    /// default
    static let `default` = DJALocalizedString("default", tableName: "Localizable", comment: "")

    /// default
    static func `default`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("default", tableName: "Localizable", comment: ""), p0)
    }

    /// defer
    static let `defer` = DJALocalizedString("defer", tableName: "Localizable", comment: "")

    /// defer
    static func `defer`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("defer", tableName: "Localizable", comment: ""), p0)
    }

    /// deinit
    static let `deinit` = DJALocalizedString("deinit", tableName: "Localizable", comment: "")

    /// deinit
    static func `deinit`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("deinit", tableName: "Localizable", comment: ""), p0)
    }

    /// do
    static let `do` = DJALocalizedString("do", tableName: "Localizable", comment: "")

    /// do
    static func `do`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("do", tableName: "Localizable", comment: ""), p0)
    }

    /// else
    static let `else` = DJALocalizedString("else", tableName: "Localizable", comment: "")

    /// else
    static func `else`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("else", tableName: "Localizable", comment: ""), p0)
    }

    /// enum
    static let `enum` = DJALocalizedString("enum", tableName: "Localizable", comment: "")

    /// enum
    static func `enum`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("enum", tableName: "Localizable", comment: ""), p0)
    }

    /// extension
    static let `extension` = DJALocalizedString("extension", tableName: "Localizable", comment: "")

    /// extension
    static func `extension`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("extension", tableName: "Localizable", comment: ""), p0)
    }

    /// fallthrough
    static let `fallthrough` = DJALocalizedString("fallthrough", tableName: "Localizable", comment: "")

    /// fallthrough
    static func `fallthrough`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("fallthrough", tableName: "Localizable", comment: ""), p0)
    }

    /// false
    static let `false` = DJALocalizedString("false", tableName: "Localizable", comment: "")

    /// false
    static func `false`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("false", tableName: "Localizable", comment: ""), p0)
    }

    /// fileprivate
    static let `fileprivate` = DJALocalizedString("fileprivate", tableName: "Localizable", comment: "")

    /// fileprivate
    static func `fileprivate`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("fileprivate", tableName: "Localizable", comment: ""), p0)
    }

    /// for
    static let `for` = DJALocalizedString("for", tableName: "Localizable", comment: "")

    /// for
    static func `for`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("for", tableName: "Localizable", comment: ""), p0)
    }

    /// func
    static let `func` = DJALocalizedString("func", tableName: "Localizable", comment: "")

    /// func
    static func `func`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("func", tableName: "Localizable", comment: ""), p0)
    }

    /// guard
    static let `guard` = DJALocalizedString("guard", tableName: "Localizable", comment: "")

    /// guard
    static func `guard`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("guard", tableName: "Localizable", comment: ""), p0)
    }

    /// if
    static let `if` = DJALocalizedString("if", tableName: "Localizable", comment: "")

    /// if
    static func `if`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("if", tableName: "Localizable", comment: ""), p0)
    }

    /// import
    static let `import` = DJALocalizedString("import", tableName: "Localizable", comment: "")

    /// import
    static func `import`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("import", tableName: "Localizable", comment: ""), p0)
    }

    /// in
    static let `in` = DJALocalizedString("in", tableName: "Localizable", comment: "")

    /// in
    static func `in`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("in", tableName: "Localizable", comment: ""), p0)
    }

    /// init
    static let `init` = DJALocalizedString("init", tableName: "Localizable", comment: "")

    /// init
    static func `init`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("init", tableName: "Localizable", comment: ""), p0)
    }

    /// inout
    static let `inout` = DJALocalizedString("inout", tableName: "Localizable", comment: "")

    /// inout
    static func `inout`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("inout", tableName: "Localizable", comment: ""), p0)
    }

    /// internal
    static let `internal` = DJALocalizedString("internal", tableName: "Localizable", comment: "")

    /// internal
    static func `internal`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("internal", tableName: "Localizable", comment: ""), p0)
    }

    /// is
    static let `is` = DJALocalizedString("is", tableName: "Localizable", comment: "")

    /// is
    static func `is`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("is", tableName: "Localizable", comment: ""), p0)
    }

    /// let
    static let `let` = DJALocalizedString("let", tableName: "Localizable", comment: "")

    /// let
    static func `let`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("let", tableName: "Localizable", comment: ""), p0)
    }

    /// nil
    static let `nil` = DJALocalizedString("nil", tableName: "Localizable", comment: "")

    /// nil
    static func `nil`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("nil", tableName: "Localizable", comment: ""), p0)
    }

    /// open
    static let `open` = DJALocalizedString("open", tableName: "Localizable", comment: "")

    /// open
    static func `open`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("open", tableName: "Localizable", comment: ""), p0)
    }

    /// operator
    static let `operator` = DJALocalizedString("operator", tableName: "Localizable", comment: "")

    /// operator
    static func `operator`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("operator", tableName: "Localizable", comment: ""), p0)
    }

    /// precedencegroup
    static let `precedencegroup` = DJALocalizedString("precedencegroup", tableName: "Localizable", comment: "")

    /// precedencegroup
    static func `precedencegroup`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("precedencegroup", tableName: "Localizable", comment: ""), p0)
    }

    /// private
    static let `private` = DJALocalizedString("private", tableName: "Localizable", comment: "")

    /// private
    static func `private`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("private", tableName: "Localizable", comment: ""), p0)
    }

    /// protocol
    static let `protocol` = DJALocalizedString("protocol", tableName: "Localizable", comment: "")

    /// protocol
    static func `protocol`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("protocol", tableName: "Localizable", comment: ""), p0)
    }

    /// public
    static let `public` = DJALocalizedString("public", tableName: "Localizable", comment: "")

    /// public
    static func `public`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("public", tableName: "Localizable", comment: ""), p0)
    }

    /// repeat
    static let `repeat` = DJALocalizedString("repeat", tableName: "Localizable", comment: "")

    /// repeat
    static func `repeat`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("repeat", tableName: "Localizable", comment: ""), p0)
    }

    /// rethrows
    static let `rethrows` = DJALocalizedString("rethrows", tableName: "Localizable", comment: "")

    /// rethrows
    static func `rethrows`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("rethrows", tableName: "Localizable", comment: ""), p0)
    }

    /// return
    static let `return` = DJALocalizedString("return", tableName: "Localizable", comment: "")

    /// return
    static func `return`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("return", tableName: "Localizable", comment: ""), p0)
    }

    /// self
    static let `self` = DJALocalizedString("self", tableName: "Localizable", comment: "")

    /// self
    static func `self`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("self", tableName: "Localizable", comment: ""), p0)
    }

    /// static
    static let `static` = DJALocalizedString("static", tableName: "Localizable", comment: "")

    /// static
    static func `static`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("static", tableName: "Localizable", comment: ""), p0)
    }

    /// struct
    static let `struct` = DJALocalizedString("struct", tableName: "Localizable", comment: "")

    /// struct
    static func `struct`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("struct", tableName: "Localizable", comment: ""), p0)
    }

    /// subscript
    static let `subscript` = DJALocalizedString("subscript", tableName: "Localizable", comment: "")

    /// subscript
    static func `subscript`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("subscript", tableName: "Localizable", comment: ""), p0)
    }

    /// super
    static let `super` = DJALocalizedString("super", tableName: "Localizable", comment: "")

    /// super
    static func `super`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("super", tableName: "Localizable", comment: ""), p0)
    }

    /// switch
    static let `switch` = DJALocalizedString("switch", tableName: "Localizable", comment: "")

    /// switch
    static func `switch`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("switch", tableName: "Localizable", comment: ""), p0)
    }

    /// throw
    static let `throw` = DJALocalizedString("throw", tableName: "Localizable", comment: "")

    /// throw
    static func `throw`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("throw", tableName: "Localizable", comment: ""), p0)
    }

    /// throws
    static let `throws` = DJALocalizedString("throws", tableName: "Localizable", comment: "")

    /// throws
    static func `throws`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("throws", tableName: "Localizable", comment: ""), p0)
    }

    /// true
    static let `true` = DJALocalizedString("true", tableName: "Localizable", comment: "")

    /// true
    static func `true`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("true", tableName: "Localizable", comment: ""), p0)
    }

    /// try
    static let `try` = DJALocalizedString("try", tableName: "Localizable", comment: "")

    /// try
    static func `try`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("try", tableName: "Localizable", comment: ""), p0)
    }

    /// typealias
    static let `typealias` = DJALocalizedString("typealias", tableName: "Localizable", comment: "")

    /// typealias
    static func `typealias`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("typealias", tableName: "Localizable", comment: ""), p0)
    }

    /// var
    static let `var` = DJALocalizedString("var", tableName: "Localizable", comment: "")

    /// var
    static func `var`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("var", tableName: "Localizable", comment: ""), p0)
    }

    /// where
    static let `where` = DJALocalizedString("where", tableName: "Localizable", comment: "")

    /// where
    static func `where`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("where", tableName: "Localizable", comment: ""), p0)
    }

    /// while
    static let `while` = DJALocalizedString("while", tableName: "Localizable", comment: "")

    /// while
    static func `while`(_ p0: Int) -> Swift.String {
        Swift.String.localizedStringWithFormat(DJALocalizedString("while", tableName: "Localizable", comment: ""), p0)
    }
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    private func plainAndPlaceholderLocalisations(forLocalisationWithKey key: String) -> [Localisation] {
        [
            Localisation(key: key, tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                Localisation.Preview(description: nil, value: key)
            ]),
            Localisation(key: key, tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .integer)], previews: [
                Localisation.Preview(description: nil, value: key)
            ])
        ]
    }
}

// MARK: - LocalizedString Function Selection

extension SwiftCodeGeneratorTests {
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithTheMigratedExtractionState() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "Migrated", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .migrated, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let migrated = DJALocalizedString("Migrated", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithTheManualExtractionState() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "Manual", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let manual = DJALocalizedString("Manual", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithTheExtractedWithValueExtractionState() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "Extracted", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .extractedWithValue, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let extracted = NSLocalizedString("Extracted", tableName: "Localizable", bundle: Bundle(for: DJAStringsBundleClass.self), comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithTheExtractedWithValueExtractionStateWhenLoadingStringsFromASwiftPackageResourceBundle() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "Extracted", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .extractedWithValue, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []),
                                 resourceBundleLocationKind: .swiftPackage)
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let extracted = NSLocalizedString("Extracted", tableName: "Localizable", bundle: Bundle.module, comment: "")
}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle.module, value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithTheStaleExtractionState() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "Stale", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .stale, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let stale = DJALocalizedString("Stale", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithNoExtractionState() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "no_extraction", tableName: "Localizable", defaultLanguageValue: nil, extractionState: nil, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let noExtraction = NSLocalizedString("no_extraction", tableName: "Localizable", bundle: Bundle(for: DJAStringsBundleClass.self), comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItUsesTheCorrectLocalizedStringFunctionForStringsWithNoExtractionStateWhenLoadingStringsFromASwiftPackageResourceBundle() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "no_extraction", tableName: "Localizable", defaultLanguageValue: nil, extractionState: nil, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []),
                                 resourceBundleLocationKind: .swiftPackage)
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let noExtraction = NSLocalizedString("no_extraction", tableName: "Localizable", bundle: Bundle.module, comment: "")
}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle.module, value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

// MARK: - Default Value Parameter

extension SwiftCodeGeneratorTests {
    func testItGeneratesTheCorrectOutputForLocalisationsWithDefaultValues() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: "Localisation", extractionState: .manual, comment: nil, placeholders: [], previews: [])
                                                                                          ],
                                                                                          childNodes: [
                                                                                            TestLocalisationsTreeNode(name: "child_one",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", defaultLanguageValue: "Child One", extractionState: .manual, comment: nil, placeholders: [], previews: []),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", defaultLanguageValue: "Child Two", extractionState: .manual, comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [])
                                                                                                                      ],
                                                                                                                      childNodes: [])]))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {

    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", value: "Localisation", comment: "")

    public enum ChildOne {

        static let one = DJALocalizedString("child_one.one", tableName: "Localizable", value: "Child One", comment: "")

        static func two(_ p0: CustomStringConvertible) -> Swift.String {
            Swift.String.localizedStringWithFormat(DJALocalizedString("child_one.two", tableName: "Localizable", value: "Child Two", comment: ""), p0.description)
        }
    }
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItGeneratesTheCorrectOutputForLocalisationsWithDefaultValuesContainingNewlines() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: "I contain a\nnewline character.", extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", value: "I contain a\\nnewline character.", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItGeneratesTheCorrectOutputForLocalisationsWithDefaultValuesContainingQuotationMarks() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: "I contain \"quotation marks\".", extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", value: "I contain \\"quotation marks\\".", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

// MARK: - Comment Parameter

extension SwiftCodeGeneratorTests {
    func testItIncludesTheLocalisationCommentsInTheCallToTheLocalizedStringFunctionAndDocumentation() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: "Comment One", placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised One")
                                                                                            ]),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: "Comment Two", placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised Two")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised One
    ///
    /// **Comment**
    /// Comment One
    static let localisationOne = DJALocalizedString("localisation_one", tableName: "Localizable", comment: "Comment One")

    /// Localised Two
    ///
    /// **Comment**
    /// Comment Two
    static let localisationTwo = DJALocalizedString("localisation_two", tableName: "Localizable", comment: "Comment Two")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectCommentWhenTheSourceFileCommentContainsNewlines() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: "Comment\nwith\nnewlines", placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Localised
    ///
    /// **Comment**
    /// Comment with newlines
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "Comment with newlines")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

// MARK: - Preview Comments

extension SwiftCodeGeneratorTests {
    func testItProducesTheCorrectDocumentationCommentForLocalisationPreviewsWithADescription() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: "Description", value: "Value")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// **Description**
    /// Value
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectDocumentationCommentsForLocalisationsWithMultiplePreviews() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: "Description One", value: "Value One"),
                                                                                                Localisation.Preview(description: "Description Two", value: "Value Two"),
                                                                                                Localisation.Preview(description: "Description Three", value: "Value Three"),
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Key: `localisation`, table name: `Localizable`
    ///
    /// **Description One**
    /// Value One
    ///
    /// **Description Two**
    /// Value Two
    ///
    /// **Description Three**
    /// Value Three
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectDocumentationCommentsForLocalisationsWithMultiplePreviewsAndAComment() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: "I have multiple previews", placeholders: [], previews: [
                                                                                                Localisation.Preview(description: "Description One", value: "Value One"),
                                                                                                Localisation.Preview(description: "Description Two", value: "Value Two"),
                                                                                                Localisation.Preview(description: "Description Three", value: "Value Three"),
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Key: `localisation`, table name: `Localizable`
    ///
    /// **Description One**
    /// Value One
    ///
    /// **Description Two**
    /// Value Two
    ///
    /// **Description Three**
    /// Value Three
    ///
    /// **Comment**
    /// I have multiple previews
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "I have multiple previews")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectDocumentationCommentsForLocalisationsWithPreviewsContainingNewlines() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Value\n\nOne")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    /// Value  One
    static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
    NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

// MARK: - Custom Formatting

extension SwiftCodeGeneratorTests {
    func testItProducesTheCorrectOutputWhenACustomFormattingConfigurationIsSpecified() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", defaultLanguageValue: nil, extractionState: .manual, comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localisation")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: []),
                                 formattingConfigurationFileURL: Bundle.module.url(forResource: "Custom", withExtension: "swift-format"))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
            /// Localisation
            static let localisation = DJALocalizedString("localisation", tableName: "Localizable", comment: "")
}

private final class DJAStringsBundleClass {}

private func DJALocalizedString(_ key: String, tableName: String? = nil, value: String = "", comment: String) -> Swift.String {
            NSLocalizedString(key, tableName: tableName, bundle: Bundle(for: DJAStringsBundleClass.self), value: value, comment: comment)
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

private struct TestLocalisationsTreeNode: LocalisationsTreeNode {
    let name: String
    let localisations: [Localisation]
    let childNodes: [TestLocalisationsTreeNode]
}
