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
                                                                                            Localisation(key: "localisation", tableName: "Localizable", placeholders: [], previews: [])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    static let localisation = NSLocalizedString("localisation", tableName: "Localizable", comment: "")
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForASingleNodeWithMultipleLocalisations() throws {
        givenASwiftCodeGenerator(withRootLocalisationsTreeNode: TestLocalisationsTreeNode(name: "Root",
                                                                                          localisations: [
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", placeholders: [], previews: []),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", placeholders: [], previews: [])
                                                                                          ],
                                                                                          childNodes: []))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    static let localisationOne = NSLocalizedString("localisation_one", tableName: "Localizable", comment: "")

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
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", placeholders: [], previews: []),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [])
                                                                                                                      ],
                                                                                                                      childNodes: []),
                                                                                            TestLocalisationsTreeNode(name: "child_two",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_two.one", tableName: "Localizable", placeholders: [], previews: []),
                                                                                                                        Localisation(key: "child_two.two", tableName: "Localizable", placeholders: [Localisation.Placeholder(name: "message_count", type: .integer)], previews: [])
                                                                                                                      ],
                                                                                                                      childNodes: [
                                                                                                                        TestLocalisationsTreeNode(name: "nested_child",
                                                                                                                                                  localisations: [
                                                                                                                                                    Localisation(key: "child_two.nested_child.one", tableName: "Localizable", placeholders: [], previews: [])
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
        static let one = NSLocalizedString("child_one.one", tableName: "Localizable", comment: "")

        static func two(_ p0: CustomStringConvertible) -> String {
            String(format: NSLocalizedString("child_one.two", tableName: "Localizable", comment: ""), p0.description)
        }
    }

    public enum ChildTwo {
        static let one = NSLocalizedString("child_two.one", tableName: "Localizable", comment: "")

        static func two(messageCount: Int) -> String {
            String(format: NSLocalizedString("child_two.two", tableName: "Localizable", comment: ""), messageCount)
        }

        public enum NestedChild {
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
                                                                                            Localisation(key: "localisation_one", tableName: "Localizable", placeholders: [], previews: []),
                                                                                            Localisation(key: "localisation_two", tableName: "Localizable", placeholders: [], previews: [])
                                                                                          ],
                                                                                          childNodes: [
                                                                                            TestLocalisationsTreeNode(name: "child_one",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_one.one", tableName: "Localizable", placeholders: [], previews: []),
                                                                                                                        Localisation(key: "child_one.two", tableName: "Localizable", placeholders: [Localisation.Placeholder(name: nil, type: .object)], previews: [])
                                                                                                                      ],
                                                                                                                      childNodes: []),
                                                                                            TestLocalisationsTreeNode(name: "child_two",
                                                                                                                      localisations: [
                                                                                                                        Localisation(key: "child_two.one", tableName: "Localizable", placeholders: [], previews: []),
                                                                                                                        Localisation(key: "child_two.two", tableName: "Localizable", placeholders: [Localisation.Placeholder(name: "message_count", type: .integer)], previews: [])
                                                                                                                      ],
                                                                                                                      childNodes: [
                                                                                                                        TestLocalisationsTreeNode(name: "nested_child",
                                                                                                                                                  localisations: [
                                                                                                                                                    Localisation(key: "child_two.nested_child.one", tableName: "Localizable", placeholders: [], previews: [])
                                                                                                                                                  ],
                                                                                                                                                  childNodes: [])
                                                                                                                      ])
                                                                                          ]))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
    static let localisationOne = NSLocalizedString("localisation_one", tableName: "Localizable", comment: "")

    static let localisationTwo = NSLocalizedString("localisation_two", tableName: "Localizable", comment: "")

    public enum ChildOne {
        static let one = NSLocalizedString("child_one.one", tableName: "Localizable", comment: "")

        static func two(_ p0: CustomStringConvertible) -> String {
            String(format: NSLocalizedString("child_one.two", tableName: "Localizable", comment: ""), p0.description)
        }
    }

    public enum ChildTwo {
        static let one = NSLocalizedString("child_two.one", tableName: "Localizable", comment: "")

        static func two(messageCount: Int) -> String {
            String(format: NSLocalizedString("child_two.two", tableName: "Localizable", comment: ""), messageCount)
        }

        public enum NestedChild {
            static let one = NSLocalizedString("child_two.nested_child.one", tableName: "Localizable", comment: "")
        }
    }
}

"""
        XCTAssertEqual(vendedSwiftCode, expectedOutput)
    }
    
    func testItProducesTheCorrectOutputForADeeplyNestedChildNodes() throws {
        let childThree = TestLocalisationsTreeNode(name: "child_three", localisations: [Localisation(key: "child_one.child_two.child_three.one", tableName: "Localizable", placeholders: [], previews: [])], childNodes: [])
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
                static let one = NSLocalizedString("child_one.child_two.child_three.one", tableName: "Localizable", comment: "")
            }
        }
    }
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
                                                                                            Localisation(key: "localisation", tableName: "Localizable", placeholders: [], previews: [])
                                                                                          ],
                                                                                          childNodes: []),
                                 formattingConfigurationFileURL: Bundle.module.url(forResource: "Custom", withExtension: "swift-format"))
        try whenSwiftCodeIsVended()
        let expectedOutput =
        """
import Foundation

public enum Root {
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
