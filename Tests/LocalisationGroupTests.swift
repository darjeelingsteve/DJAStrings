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

// MARK: - Comments

extension LocalisationGroupTests {
    func testItUsesTheCommentsFromTheStringsFile() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].comment, "String with placeholder")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].comment, "Plain string")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].comment, "String with positional placeholders")
        XCTAssertNil(localisationGroup.childGroups[0].localisations[3].comment)
    }
}

// MARK: - Placeholders

extension LocalisationGroupTests {
    func testItProducesTheCorrectPlaceholdersForLocalisationsWithPluralisedVariations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders.count, 1)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders, [
            Localisation.Placeholder(name: nil, type: .integer)
        ])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders.count, 2)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].placeholders, [
            Localisation.Placeholder(name: "message_count", type: .integer),
            Localisation.Placeholder(name: "inbox_count", type: .integer),
        ])
    }
    
    func testItProducesTheCorrectPlaceholdersForLocalisationsWithoutPluralisedVariations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "strings.placeholder")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].placeholders, [
            Localisation.Placeholder(name: nil, type: .object)
        ])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].key, "strings.positional_placeholders")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].placeholders, [
            Localisation.Placeholder(name: nil, type: .integer),
            Localisation.Placeholder(name: nil, type: .unsignedInteger)
        ])
    }
    
    func testItProducesNoPlaceholdersForLocalisationsWithoutPlaceholderTokens() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "strings.plain")
        XCTAssertTrue(localisationGroup.childGroups[0].localisations[1].placeholders.isEmpty)
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].key, "strings.stale")
        XCTAssertTrue(localisationGroup.childGroups[0].localisations[3].placeholders.isEmpty)
    }
    
    func testItProducesTheCorrectPlaceholdersForDeviceVariedLocalisationsWithPluralisedVariations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Device-varied Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "device.tap")
        XCTAssertTrue(localisationGroup.childGroups[0].localisations[0].placeholders.isEmpty)
        
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].key, "device.messages.cta")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].placeholders, [
            Localisation.Placeholder(name: nil, type: .integer)
        ])
        
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[1].localisations[0].key, "device.messages_and_inbox_count.cta")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[1].localisations[0].placeholders, [
            Localisation.Placeholder(name: "message_count", type: .integer),
            Localisation.Placeholder(name: "inbox_count", type: .integer),
        ])
    }
    
    func testItProducesPlaceholdersForAllPlaceholderTokenTypes() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "All Placeholder Type Localisations")
        XCTAssertEqual(localisationGroup.localisations.count, 1)
        XCTAssertEqual(localisationGroup.localisations[0].key, "placeholders")
        XCTAssertEqual(localisationGroup.localisations[0].tableName, "All Placeholder Type Localisations")
        XCTAssertEqual(localisationGroup.localisations[0].placeholders, [
            Localisation.Placeholder(name: nil, type: .object),
            Localisation.Placeholder(name: nil, type: .float),
            Localisation.Placeholder(name: nil, type: .float),
            Localisation.Placeholder(name: nil, type: .float),
            Localisation.Placeholder(name: nil, type: .float),
            Localisation.Placeholder(name: nil, type: .float),
            Localisation.Placeholder(name: nil, type: .integer),
            Localisation.Placeholder(name: nil, type: .integer),
            Localisation.Placeholder(name: nil, type: .integer),
            Localisation.Placeholder(name: nil, type: .integer),
            Localisation.Placeholder(name: nil, type: .integer),
            Localisation.Placeholder(name: nil, type: .unsignedInteger),
            Localisation.Placeholder(name: nil, type: .unsignedInteger),
            Localisation.Placeholder(name: nil, type: .char),
            Localisation.Placeholder(name: nil, type: .cString),
            Localisation.Placeholder(name: nil, type: .pointer)
        ])
    }
}

// MARK: - Previews

extension LocalisationGroupTests {
    func testItGeneratesTheCorrectPreviewsForSimpleLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Simple Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "strings.placeholder")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews, [Localisation.Preview(description: nil, value: "String with placeholder %@")])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "strings.plain")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews, [Localisation.Preview(description: nil, value: "Plain String")])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].key, "strings.positional_placeholders")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[2].previews, [Localisation.Preview(description: nil, value: "String with %1$d positional placeholders %2$lu")])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].key, "strings.stale")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[3].previews, [Localisation.Preview(description: nil, value: "Stale string")])
    }
    
    func testItGeneratesTheCorrectPreviewsForPluralisedLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Pluralised Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "messages.count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews, [
            Localisation.Preview(description: "Zero", value: "You have no new messages"),
            Localisation.Preview(description: "One", value: "You have %d new message"),
            Localisation.Preview(description: "Other", value: "You have %d new messages")
        ])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].key, "messages.message_and_inbox_count")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[1].previews, [
            Localisation.Preview(description: "messageCount Zero, inboxCount Zero", value: "You have no messages across no inboxes"),
            Localisation.Preview(description: "messageCount Zero, inboxCount One", value: "You have no messages across `inboxCount` inbox"),
            Localisation.Preview(description: "messageCount Zero, inboxCount Other", value: "You have no messages across `inboxCount` inboxes"),
            Localisation.Preview(description: "messageCount One, inboxCount Zero", value: "You have `messageCount` message across no inboxes"),
            Localisation.Preview(description: "messageCount One, inboxCount One", value: "You have `messageCount` message across `inboxCount` inbox"),
            Localisation.Preview(description: "messageCount One, inboxCount Other", value: "You have `messageCount` message across `inboxCount` inboxes"),
            Localisation.Preview(description: "messageCount Other, inboxCount Zero", value: "You have `messageCount` messages across no inboxes"),
            Localisation.Preview(description: "messageCount Other, inboxCount One", value: "You have `messageCount` messages across `inboxCount` inbox"),
            Localisation.Preview(description: "messageCount Other, inboxCount Other", value: "You have `messageCount` messages across `inboxCount` inboxes"),
        ])
    }
    
    func testItGeneratesTheCorrectPreviewsForDeviceVaryingLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Namespace-keyed Device-varied Localisations")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].key, "device.messages.cta")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[0].localisations[0].previews, [
            Localisation.Preview(description: "Device iPod, One", value: "Tap to view your %d message."),
            Localisation.Preview(description: "Device iPod, Other", value: "Tap to view your %d messages."),
            Localisation.Preview(description: "Device Other", value: "Tap to view your %d messages.")
        ])
        
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[1].localisations[0].key, "device.messages_and_inbox_count.cta")
        XCTAssertEqual(localisationGroup.childGroups[0].childGroups[1].localisations[0].previews, [
            Localisation.Preview(description: "Device Mac, messageCount One, inboxCount One", value: "Click to view your `messageCount` message in `inboxCount` inbox."),
            Localisation.Preview(description: "Device Mac, messageCount One, inboxCount Other", value: "Click to view your `messageCount` message in `inboxCount` inboxes."),
            Localisation.Preview(description: "Device Mac, messageCount Other, inboxCount One", value: "Click to view your `messageCount` messages in `inboxCount` inbox."),
            Localisation.Preview(description: "Device Mac, messageCount Other, inboxCount Other", value: "Click to view your `messageCount` messages in `inboxCount` inboxes."),
            Localisation.Preview(description: "Device Other, messageCount One, inboxCount One", value: "Tap to view your `messageCount` message in `inboxCount` inbox."),
            Localisation.Preview(description: "Device Other, messageCount One, inboxCount Other", value: "Tap to view your `messageCount` message in `inboxCount` inboxes."),
            Localisation.Preview(description: "Device Other, messageCount Other, inboxCount One", value: "Tap to view your `messageCount` messages in `inboxCount` inbox."),
            Localisation.Preview(description: "Device Other, messageCount Other, inboxCount Other", value: "Tap to view your `messageCount` messages in `inboxCount` inboxes.")
        ])
        
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].key, "device.tap")
        XCTAssertEqual(localisationGroup.childGroups[0].localisations[0].previews, [
            Localisation.Preview(description: "Device iPhone", value: "Tap your iPhone"),
            Localisation.Preview(description: "Device iPod", value: "Tap your iPod"),
            Localisation.Preview(description: "Device iPad", value: "Tap your iPad"),
            Localisation.Preview(description: "Device Apple Watch", value: "Tap your Apple Watch"),
            Localisation.Preview(description: "Device Apple TV", value: "Click your Apple TV"),
            Localisation.Preview(description: "Device Mac", value: "Click your Mac"),
            Localisation.Preview(description: "Device Other", value: "Tap your device")
        ])
    }
    
    func testItGeneratesTheCorrectPreviewsForVariableWidthLocalisations() throws {
        givenALocalisationGroup()
        try whenAParsedStringsDocumentIsApplied(withFilename: "Variable-width Localisations")
        XCTAssertEqual(localisationGroup.localisations[0].key, "greetings_message")
        XCTAssertEqual(localisationGroup.localisations[0].previews, [
            Localisation.Preview(description: "Width 1", value: "Hi!"),
            Localisation.Preview(description: "Width 20", value: "Hello!"),
            Localisation.Preview(description: "Width 70", value: "Greetings and Salutations!")
        ])
        
        XCTAssertEqual(localisationGroup.localisations[1].key, "message_count")
        XCTAssertEqual(localisationGroup.localisations[1].previews, [
            Localisation.Preview(description: "Width 20, messageCount20 Zero, inboxCount20 Zero", value: "No msgs in no boxes."),
            Localisation.Preview(description: "Width 20, messageCount20 Zero, inboxCount20 One", value: "No msgs in `inboxCount20` box."),
            Localisation.Preview(description: "Width 20, messageCount20 Zero, inboxCount20 Other", value: "No msgs in `inboxCount20` boxes."),
            Localisation.Preview(description: "Width 20, messageCount20 One, inboxCount20 Zero", value: "`messageCount20` msg in no boxes."),
            Localisation.Preview(description: "Width 20, messageCount20 One, inboxCount20 One", value: "`messageCount20` msg in `inboxCount20` box."),
            Localisation.Preview(description: "Width 20, messageCount20 One, inboxCount20 Other", value: "`messageCount20` msg in `inboxCount20` boxes."),
            Localisation.Preview(description: "Width 20, messageCount20 Other, inboxCount20 Zero", value: "`messageCount20` msgs in no boxes."),
            Localisation.Preview(description: "Width 20, messageCount20 Other, inboxCount20 One", value: "`messageCount20` msgs in `inboxCount20` box."),
            Localisation.Preview(description: "Width 20, messageCount20 Other, inboxCount20 Other", value: "`messageCount20` msgs in `inboxCount20` boxes."),
            Localisation.Preview(description: "Width 70, messageCount70 Zero, inboxCount70 Zero", value: "You have no messages in no inboxes."),
            Localisation.Preview(description: "Width 70, messageCount70 Zero, inboxCount70 One", value: "You have no messages in `inboxCount70` inbox."),
            Localisation.Preview(description: "Width 70, messageCount70 Zero, inboxCount70 Other", value: "You have no messages in `inboxCount70` inboxes."),
            Localisation.Preview(description: "Width 70, messageCount70 One, inboxCount70 Zero", value: "You have `messageCount70` message in no inboxes."),
            Localisation.Preview(description: "Width 70, messageCount70 One, inboxCount70 One", value: "You have `messageCount70` message in `inboxCount70` inbox."),
            Localisation.Preview(description: "Width 70, messageCount70 One, inboxCount70 Other", value: "You have `messageCount70` message in `inboxCount70` inboxes."),
            Localisation.Preview(description: "Width 70, messageCount70 Other, inboxCount70 Zero", value: "You have `messageCount70` messages in no inboxes."),
            Localisation.Preview(description: "Width 70, messageCount70 Other, inboxCount70 One", value: "You have `messageCount70` messages in `inboxCount70` inbox."),
            Localisation.Preview(description: "Width 70, messageCount70 Other, inboxCount70 Other", value: "You have `messageCount70` messages in `inboxCount70` inboxes.")
        ])
        
        XCTAssertEqual(localisationGroup.localisations[2].key, "width_varied_by_device")
        XCTAssertEqual(localisationGroup.localisations[2].previews, [
            Localisation.Preview(description: "Width 20, Device iPod", value: "Hello iPod!"),
            Localisation.Preview(description: "Width 20, Device Other", value: "Hello!"),
            Localisation.Preview(description: "Width 70, Device iPod", value: "Greetings and Salutations iPod!"),
            Localisation.Preview(description: "Width 70, Device Other", value: "Greetings and Salutations!")
        ])
        
        XCTAssertEqual(localisationGroup.localisations[3].key, "width_varied_by_plural")
        XCTAssertEqual(localisationGroup.localisations[3].previews, [
            Localisation.Preview(description: "Width 20, One", value: "Hello %d!"),
            Localisation.Preview(description: "Width 20, Other", value: "Hellos %d!"),
            Localisation.Preview(description: "Width 70, One", value: "Greetings and Salutation %d!"),
            Localisation.Preview(description: "Width 70, Other", value: "Greetings and Salutations %d!")
        ])
    }
}
