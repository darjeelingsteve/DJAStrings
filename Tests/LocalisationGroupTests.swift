//
//  LocalisationGroupTests.swift
//
//
//  Created by Stephen Anthony on 13/06/2023.
//

import XCTest
@testable import DJAStrings

final class LocalisationGroupTests: XCTestCase {
    private var localisationGroup: LocalisationGroup!
    
    override func tearDown() {
        localisationGroup = nil
        super.tearDown()
    }
    
    func testItProducesAGroupWithTheGivenName() {
        givenALocalisationGroup(withName: "Group Name")
        XCTAssertEqual(localisationGroup.name, "Group Name")
    }
    
    func testItProducesNoGroupsWhenThereAreNoLocalisableKeysSuitableForUseAsSwiftSymbols() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Simple Localisations")
        XCTAssertTrue(localisationGroup.localisations.isEmpty)
        XCTAssertTrue(localisationGroup.childGroups.isEmpty)
    }
    
    private func givenALocalisationGroup(withName name: String = "") {
        localisationGroup = LocalisationGroup(name: name)
    }
    
    private func whenAParsedStringsDocumentIsApplied(withFilename filename: String, subdirectories: [String]? = nil) throws {
        let url: URL
        if let subdirectories {
            url = Bundle.module.resourceURL!.appending(path: (["XCStrings Files"] + subdirectories).joined(separator: "/")).appending(path: filename).appendingPathExtension("xcstrings")
        } else {
            url = Bundle.module.urls(forResourcesWithExtension: "xcstrings", subdirectory: "XCStrings Files")!.first { $0.lastPathComponent.hasPrefix(filename) }!
        }
        let parsedStringsDocument = try ParsedStringsDocument(stringsDocumentURL: url)
        try localisationGroup.applying(document: parsedStringsDocument)
    }
}

// MARK: - Namespacing

extension LocalisationGroupTests {
    func testItBreaksUpNamespacedLocalisationsInToAppropriateChildGroups() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Pluralised Localisations")
        XCTAssertTrue(localisationGroup.localisations.isEmpty)
        XCTAssertEqual(localisationGroup.childGroups.count, 1)
        XCTAssertEqual(localisationGroup.childGroups[0].name, "messages")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations.count, 2)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "messages.count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].tableName, "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "messages.message_and_inbox_count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].tableName, "Namespace-keyed Pluralised Localisations")
    }
    
    func testItMergesLocalisationsFromLocalisationsInNamespacesAcrossMultipleFiles() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Localizable One", subdirectories: ["Overlapping Namespaces"])
        try whenAParsedStringsDocumentIsApplied(withFilename: "Localizable Two", subdirectories: ["Overlapping Namespaces"])
        XCTAssertEqual(localisationGroup.localisations.count, 3)
        XCTAssertEqual(localisationGroup.localisations[0].key, "cancel")
        XCTAssertEqual(localisationGroup.localisations[0].tableName, "Localizable One")
        XCTAssertTrue(localisationGroup.localisations[0].placeholders.isEmpty)
        XCTAssertEqual(localisationGroup.localisations[1].key, "done")
        XCTAssertEqual(localisationGroup.localisations[1].tableName, "Localizable One")
        XCTAssertTrue(localisationGroup.localisations[1].placeholders.isEmpty)
        XCTAssertEqual(localisationGroup.localisations[2].key, "ok")
        XCTAssertEqual(localisationGroup.localisations[2].tableName, "Localizable One")
        XCTAssertTrue(localisationGroup.localisations[2].placeholders.isEmpty)
        
        XCTAssertEqual(localisationGroup.childGroups.count, 2)
        XCTAssertEqual(localisationGroup.childGroups[0].name, "namespace_one")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations.count, 5)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "namespace_one.first_localisation")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].tableName, "Localizable One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "namespace_one.second_localisation")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].tableName, "Localizable One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].key, "namespace_one.third_localisation")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].tableName, "Localizable One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].key, "namespace_one.fifth_localisation")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].tableName, "Localizable Two")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[4].key, "namespace_one.fourth_localisation")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[4].tableName, "Localizable Two")
        
        XCTAssertEqual(localisationGroup.childGroups[1].name, "namespace_two")
        XCTAssertEqual(localisationGroup.childGroups[1].localisations.count, 2)
        XCTAssertEqual(localisationGroup.childGroups[1].localisations[0].key, "namespace_two.first_localisation")
        XCTAssertEqual(localisationGroup.childGroups[1].localisations[0].tableName, "Localizable Two")
        XCTAssertEqual(localisationGroup.childGroups[1].localisations[1].key, "namespace_two.second_localisation")
        XCTAssertEqual(localisationGroup.childGroups[1].localisations[1].tableName, "Localizable Two")
    }
}

// MARK: - Placeholders

extension LocalisationGroupTests {
    func testItProducesTheCorrectPlaceholdersForLocalisationsWithPluralisedVariations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders.count, 1)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[0].placeholders[0].name)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders[0].type, .integer)
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders.count, 2)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders[0].name, "message_count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders[0].type, .integer)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders[1].name, "inbox_count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders[1].type, .integer)
    }
    
    func testItProducesTheCorrectPlaceholdersForLocalisationsWithoutPluralisedVariations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "strings.placeholder")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders.count, 1)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[0].placeholders[0].name)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders[0].type, .object)
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].key, "strings.positional_placeholders")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].placeholders.count, 2)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[2].placeholders[0].name)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].placeholders[0].type, .integer)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[2].placeholders[1].name)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].placeholders[1].type, .unsignedInteger)
    }
    
    func testItProducesNoPlaceholdersForLocalisationsWithoutPlaceholderTokens() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "strings.plain")
        XCTAssertTrue(localisationGroup.childGroups[0].localisations[1].placeholders.isEmpty)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].key, "strings.stale")
        XCTAssertTrue(localisationGroup.childGroups[0].localisations[3].placeholders.isEmpty)
    }
    
    func testItproducesPlaceholdersForAllPlaceholderTokenTypes() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "All Placeholder Type Localisations")
        XCTAssertEqual(localisationGroup.localisations.count, 1)
        XCTAssertEqual(localisationGroup.localisations[0].key, "placeholders")
        XCTAssertEqual(localisationGroup.localisations[0].tableName, "All Placeholder Type Localisations")
        XCTAssertEqual(localisationGroup.localisations[0].placeholders.count, 16)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[0].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[0].type, .object)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[1].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[1].type, .float)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[2].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[2].type, .float)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[3].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[3].type, .float)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[4].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[4].type, .float)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[5].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[5].type, .float)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[6].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[6].type, .integer)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[7].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[7].type, .integer)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[8].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[8].type, .integer)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[9].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[9].type, .integer)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[10].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[10].type, .integer)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[11].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[11].type, .unsignedInteger)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[12].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[12].type, .unsignedInteger)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[13].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[13].type, .char)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[14].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[14].type, .cString)
        XCTAssertNil(localisationGroup.localisations[0].placeholders[15].name)
        XCTAssertEqual(localisationGroup.localisations[0].placeholders[15].type, .pointer)
    }
}

// MARK: - Previews

extension LocalisationGroupTests {
    func testItGeneratesTheCorrectPreviewsForSimpleLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "strings.placeholder")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews.count, 1)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[0].previews[0].description)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[0].value, "String with placeholder %@")
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "strings.plain")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews.count, 1)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[1].previews[0].description)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[0].value, "Plain String")
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].key, "strings.positional_placeholders")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].previews.count, 1)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[2].previews[0].description)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].previews[0].value, "String with %1$d positional placeholders %2$lu")
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].key, "strings.stale")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].previews.count, 1)
        XCTAssertNil(localisationGroup.childGroups[0].localisations[3].previews[0].description)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].previews[0].value, "Stale string")
    }
    
    func testItGeneratesTheCorrectPreviewsForPluralisedLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "messages.count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews.count, 3)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[0].description, "Zero")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[0].value, "You have no new messages")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[1].description, "One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[1].value, "You have %d new message")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[2].description, "Other")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[2].value, "You have %d new messages")
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "messages.message_and_inbox_count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews.count, 9)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[0].description, "messageCount Zero, inboxCount Zero")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[0].value, "You have no messages across no inboxes")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[1].description, "messageCount Zero, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[1].value, "You have no messages across `inboxCount` inbox")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[2].description, "messageCount Zero, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[2].value, "You have no messages across `inboxCount` inboxes")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[3].description, "messageCount One, inboxCount Zero")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[3].value, "You have `messageCount` message across no inboxes")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[4].description, "messageCount One, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[4].value, "You have `messageCount` message across `inboxCount` inbox")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[5].description, "messageCount One, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[5].value, "You have `messageCount` message across `inboxCount` inboxes")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[6].description, "messageCount Other, inboxCount Zero")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[6].value, "You have `messageCount` messages across no inboxes")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[7].description, "messageCount Other, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[7].value, "You have `messageCount` messages across `inboxCount` inbox")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[8].description, "messageCount Other, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews[8].value, "You have `messageCount` messages across `inboxCount` inboxes")
    }
    
    func testItGeneratesTheCorrectPreviewsForDeviceVaryingLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Device-varied Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].key, "device.messages.cta")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews.count, 8)
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[0].description, "Device Mac, messageCount One, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[0].value, "Click to view your `messageCount` message in `inboxCount` inbox.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[1].description, "Device Mac, messageCount One, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[1].value, "Click to view your `messageCount` message in `inboxCount` inboxes.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[2].description, "Device Mac, messageCount Other, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[2].value, "Click to view your `messageCount` messages in `inboxCount` inbox.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[3].description, "Device Mac, messageCount Other, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[3].value, "Click to view your `messageCount` messages in `inboxCount` inboxes.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[4].description, "Device Other, messageCount One, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[4].value, "Tap to view your `messageCount` message in `inboxCount` inbox.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[5].description, "Device Other, messageCount One, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[5].value, "Tap to view your `messageCount` message in `inboxCount` inboxes.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[6].description, "Device Other, messageCount Other, inboxCount One")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[6].value, "Tap to view your `messageCount` messages in `inboxCount` inbox.")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[7].description, "Device Other, messageCount Other, inboxCount Other")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews[7].value, "Tap to view your `messageCount` messages in `inboxCount` inboxes.")
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "device.tap")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews.count, 7)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[0].description, "iPhone")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[0].value, "Tap your iPhone")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[1].description, "iPod")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[1].value, "Tap your iPod")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[2].description, "iPad")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[2].value, "Tap your iPad")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[3].description, "Apple Watch")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[3].value, "Tap your Apple Watch")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[4].description, "Apple TV")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[4].value, "Click your Apple TV")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[5].description, "Mac")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[5].value, "Click your Mac")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[6].description, "Other")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews[6].value, "Tap your device")
    }
    
    func testItGeneratesTheCorrectPreviewsForVariableWidthLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Variable-width Localisations")
        XCTAssertEqual(localisationGroup.localisations[0].key, "greetings_message")
        XCTAssertEqual(localisationGroup.localisations[0].previews.count, 3)
        XCTAssertEqual(localisationGroup.localisations[0].previews[0].description, "Width 1")
        XCTAssertEqual(localisationGroup.localisations[0].previews[0].value, "Hi!")
        XCTAssertEqual(localisationGroup.localisations[0].previews[1].description, "Width 20")
        XCTAssertEqual(localisationGroup.localisations[0].previews[1].value, "Hello!")
        XCTAssertEqual(localisationGroup.localisations[0].previews[2].description, "Width 70")
        XCTAssertEqual(localisationGroup.localisations[0].previews[2].value, "Greetings and Salutations!")
        
        XCTAssertEqual(localisationGroup.localisations[1].key, "message_count")
        XCTAssertEqual(localisationGroup.localisations[1].previews.count, 18)
        XCTAssertEqual(localisationGroup.localisations[1].previews[0].description, "Width 20, messageCount20 Zero, inboxCount20 Zero")
        XCTAssertEqual(localisationGroup.localisations[1].previews[0].value, "No msgs in no boxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[1].description, "Width 20, messageCount20 Zero, inboxCount20 One")
        XCTAssertEqual(localisationGroup.localisations[1].previews[1].value, "No msgs in `inboxCount20` box.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[2].description, "Width 20, messageCount20 Zero, inboxCount20 Other")
        XCTAssertEqual(localisationGroup.localisations[1].previews[2].value, "No msgs in `inboxCount20` boxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[3].description, "Width 20, messageCount20 One, inboxCount20 Zero")
        XCTAssertEqual(localisationGroup.localisations[1].previews[3].value, "`messageCount20` msg in no boxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[4].description, "Width 20, messageCount20 One, inboxCount20 One")
        XCTAssertEqual(localisationGroup.localisations[1].previews[4].value, "`messageCount20` msg in `inboxCount20` box.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[5].description, "Width 20, messageCount20 One, inboxCount20 Other")
        XCTAssertEqual(localisationGroup.localisations[1].previews[5].value, "`messageCount20` msg in `inboxCount20` boxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[6].description, "Width 20, messageCount20 Other, inboxCount20 Zero")
        XCTAssertEqual(localisationGroup.localisations[1].previews[6].value, "`messageCount20` msgs in no boxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[7].description, "Width 20, messageCount20 Other, inboxCount20 One")
        XCTAssertEqual(localisationGroup.localisations[1].previews[7].value, "`messageCount20` msgs in `inboxCount20` box.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[8].description, "Width 20, messageCount20 Other, inboxCount20 Other")
        XCTAssertEqual(localisationGroup.localisations[1].previews[8].value, "`messageCount20` msgs in `inboxCount20` boxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[9].description, "Width 70, messageCount70 Zero, inboxCount70 Zero")
        XCTAssertEqual(localisationGroup.localisations[1].previews[9].value, "You have no messages in no inboxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[10].description, "Width 70, messageCount70 Zero, inboxCount70 One")
        XCTAssertEqual(localisationGroup.localisations[1].previews[10].value, "You have no messages in `inboxCount70` inbox.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[11].description, "Width 70, messageCount70 Zero, inboxCount70 Other")
        XCTAssertEqual(localisationGroup.localisations[1].previews[11].value, "You have no messages in `inboxCount70` inboxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[12].description, "Width 70, messageCount70 One, inboxCount70 Zero")
        XCTAssertEqual(localisationGroup.localisations[1].previews[12].value, "You have `messageCount70` message in no inboxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[13].description, "Width 70, messageCount70 One, inboxCount70 One")
        XCTAssertEqual(localisationGroup.localisations[1].previews[13].value, "You have `messageCount70` message in `inboxCount70` inbox.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[14].description, "Width 70, messageCount70 One, inboxCount70 Other")
        XCTAssertEqual(localisationGroup.localisations[1].previews[14].value, "You have `messageCount70` message in `inboxCount70` inboxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[15].description, "Width 70, messageCount70 Other, inboxCount70 Zero")
        XCTAssertEqual(localisationGroup.localisations[1].previews[15].value, "You have `messageCount70` messages in no inboxes.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[16].description, "Width 70, messageCount70 Other, inboxCount70 One")
        XCTAssertEqual(localisationGroup.localisations[1].previews[16].value, "You have `messageCount70` messages in `inboxCount70` inbox.")
        XCTAssertEqual(localisationGroup.localisations[1].previews[17].description, "Width 70, messageCount70 Other, inboxCount70 Other")
        XCTAssertEqual(localisationGroup.localisations[1].previews[17].value, "You have `messageCount70` messages in `inboxCount70` inboxes.")
    }
}
