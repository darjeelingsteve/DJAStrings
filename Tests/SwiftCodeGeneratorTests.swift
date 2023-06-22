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
    
    private func givenASwiftCodeGenerator(withRootLocalisationsTreeNode rootLocalisationsTreeNode: LocalisationsTreeNode, formattingConfigurationFileURL: URL? = nil) {
        swiftCodeGenerator = SwiftCodeGenerator(rootLocalisationsTreeNode: rootLocalisationsTreeNode, formattingConfigurationFileURL: formattingConfigurationFileURL)
    }
    
    private func whenSwiftCodeIsVended() throws {
        vendedSwiftCode = try swiftCodeGenerator.swiftSource
    }
}

// MARK: - Enum Generation

extension SwiftCodeGeneratorTests {
    func testItProducesTheCorrectOutputForASingleNodeWithOneLocalisations() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
    static let localisation = NSLocalizedString("localisation", tableName: "Localizable", comment: "")
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForASingleNodeWithMultipleLocalisations() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised One")
                                                                                            ]),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
    static let localisationOne = NSLocalizedString("localisation_one", tableName: "Localizable", comment: "")

    /// Localised Two
    static let localisationTwo = NSLocalizedString("localisation_two", tableName: "Localizable", comment: "")
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
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: []),
                                                                                            TestLocalisationsTreeNode(name: "child_two",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_two.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_two.two", tableName: "Localizable", comment: nil, placeholders: [Localisation.Placeholder(name: "message_count", type: .integer)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: [
                                                                                                                        TestLocalisationsTreeNode(name: "nested_child",
                                                                                                                                                  localisations: [
                                                                                                                                                    Localisation(key: "child_two.nested_child.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
        static let one = NSLocalizedString("child_one.one", tableName: "Localizable", comment: "")

        /// Child One Two
        static func two(_ p0: CustomStringConvertible) -> String {
            String(format: NSLocalizedString("child_one.two", tableName: "Localizable", comment: ""), p0.description)
        }
    }

    public enum ChildTwo {
        /// Child Two One
        static let one = NSLocalizedString("child_two.one", tableName: "Localizable", comment: "")

        /// Child Two Two
        static func two(messageCount: Int) -> String {
            String(format: NSLocalizedString("child_two.two", tableName: "Localizable", comment: ""), messageCount)
        }

        public enum NestedChild {
            /// Child Two Nested One
            static let one = NSLocalizedString("child_two.nested_child.one", tableName: "Localizable", comment: "")
        }
    }
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForASingleNodeWithMultipleLocalisationsAndMultipleChildNodes() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localisation One")
                                                                                            ]),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localisation Two")
                                                                                            ])
                                                                                          ],
                                                                                          childNodes: [
                                                                                            TestLocalisationsTreeNode(name: "child_one",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", comment: nil, placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child One Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: []),
                                                                                            TestLocalisationsTreeNode(name: "child_two",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_two.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two One")
                                                                                                                        ]),
                                                                                                                        Localisation(key: "child_two.two", tableName: "Localizable", comment: nil, placeholders: [Localisation.Placeholder(name: "message_count", type: .integer)], previews: [
                                                                                                                            Localisation.Preview(description: nil, value: "Child Two Two")
                                                                                                                        ])
                                                                                                                      ],
                                                                                                                      childNodes: [
                                                                                                                        TestLocalisationsTreeNode(name: "nested_child",
                                                                                                                                                  localisations: [
                                                                                                                                                    Localisation(key: "child_two.nested_child.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
    static let localisationOne = NSLocalizedString("localisation_one", tableName: "Localizable", comment: "")

    /// Localisation Two
    static let localisationTwo = NSLocalizedString("localisation_two", tableName: "Localizable", comment: "")

    public enum ChildOne {
        /// Child One One
        static let one = NSLocalizedString("child_one.one", tableName: "Localizable", comment: "")

        /// Child One Two
        static func two(_ p0: CustomStringConvertible) -> String {
            String(format: NSLocalizedString("child_one.two", tableName: "Localizable", comment: ""), p0.description)
        }
    }

    public enum ChildTwo {
        /// Child Two One
        static let one = NSLocalizedString("child_two.one", tableName: "Localizable", comment: "")

        /// Child Two Two
        static func two(messageCount: Int) -> String {
            String(format: NSLocalizedString("child_two.two", tableName: "Localizable", comment: ""), messageCount)
        }

        public enum NestedChild {
            /// Child Two Nested One
            static let one = NSLocalizedString("child_two.nested_child.one", tableName: "Localizable", comment: "")
        }
    }
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForADeeplyNestedChildNodes() throws {
        let childThree = TestLocalisationsTreeNode(name: "child_three", localisations: [Localisation(key: "child_one.child_two.child_three.one", tableName: "Localizable", comment: nil, placeholders: [], previews: [Localisation.Preview(description: nil, value: "Child Three")])], childNodes: [])
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
                static let one = NSLocalizedString("child_one.child_two.child_three.one", tableName: "Localizable", comment: "")
            }
        }
    }
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
}

// MARK: - Comment Parameter

extension SwiftCodeGeneratorTests {
    func testItIncludesTheLocalisationCommentsInTheCallToTheLocalizedStringFunction() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", comment: "Comment One", placeholders: [], previews: [
                                                                                                Localisation.Preview(description: nil, value: "Localised One")
                                                                                            ]),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", comment: "Comment Two", placeholders: [], previews: [
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
    static let localisationOne = NSLocalizedString("localisation_one", tableName: "Localizable", comment: "Comment One")

    /// Localised Two
    static let localisationTwo = NSLocalizedString("localisation_two", tableName: "Localizable", comment: "Comment Two")
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectCommentWhenTheSourceFileCommentContainsNewlines() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", comment: "Comment\nwith\nnewlines", placeholders: [], previews: [
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
    static let localisation = NSLocalizedString("localisation", tableName: "Localizable", comment: "Comment with newlines")
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
                                                                                            Localisation(key: "localisation", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
    static let localisation = NSLocalizedString("localisation", tableName: "Localizable", comment: "")
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectDocumentationCommentsForLocalisationsWithMultiplePreviews() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
    static let localisation = NSLocalizedString("localisation", tableName: "Localizable", comment: "")
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
                                                                                            Localisation(key: "localisation", tableName: "Localizable", comment: nil, placeholders: [], previews: [
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
            static let localisation = NSLocalizedString("localisation", tableName: "Localizable", comment: "")
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
