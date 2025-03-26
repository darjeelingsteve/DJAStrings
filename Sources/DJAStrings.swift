// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

@main
struct DJAStrings: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: nil,
        abstract: "Generates Swift enums representing the localized strings from one or more `.xcstrings` files.",
        subcommands: []
    )
    
    @Option(name: .shortAndLong, help: "The name of the the top-level namespace in the output Swift source file.")
    private var topLevelLocalisationNamespace: String = "DJAStrings"
    
    @Flag(name: .shortAndLong, help: "When enabled, includes the localisation table name as a namespace in the output Swift source file.")
    private var includesTableNameNamespaces: Bool = false
    
    @Option(name: .long, help: "Determines the bundle location used by the generated code to look for localisation assets.")
    private var resourceBundleLocationKind: ResourceBundleLocationKind = .standard
    
    @Option(name: .shortAndLong, help: "The path to the directory where the output of the command should be written.")
    private var outputDirectory: String = FileManager.default.currentDirectoryPath
    
    @Option(name: .shortAndLong, help: "The path to a swift-format configuration file used to format the command's output.")
    private var formattingConfigurationFilePath: String? = nil
    
    /// The paths to the `.xcstrings` files passed to the command.
    @Argument var inputFiles: [String] = []
    
    mutating func run() throws {
        guard topLevelLocalisationNamespace.rangeOfCharacter(from: .alphanumerics.inverted) == nil else {
            throw DJAStringsError.invalidTopLevelLocalisationNamespace(topLevelLocalisationNamespace)
        }
        let xcStringsFileURLs = Set(inputFiles.filter { $0.hasSuffix(".xcstrings") }).map { URL(fileURLWithPath: $0) }
        guard !xcStringsFileURLs.isEmpty else {
            throw DJAStringsError.noValidInputFiles(inputFiles)
        }
        let parsedXCStringsDocuments = try xcStringsFileURLs.map { xcStringsFileURL in
            try ParsedStringsDocument(stringsDocumentURL: xcStringsFileURL)
        }
        let rootLocalisationGroup = LocalisationGroup(name: topLevelLocalisationNamespace)
        try parsedXCStringsDocuments.forEach { try rootLocalisationGroup.applying(document: $0,
                                                                                  incorporatesTableNamesInChildGroups: includesTableNameNamespaces) }
        
        let outputDirectoryURL = URL(fileURLWithPath: outputDirectory)
        let outputPathURL = outputDirectoryURL
            .appendingPathComponent(topLevelLocalisationNamespace)
            .appendingPathExtension("swift")
        
        let formattingConfigurationFileURL = formattingConfigurationFilePath != nil ? URL(fileURLWithPath: formattingConfigurationFilePath!) : nil
        
        let outputString = SourceFileDecorator().addAttributionDocumentation(forFilenameAndExtension: outputPathURL.lastPathComponent,
                                                                             sourceFileContents: try SwiftCodeGenerator(rootLocalisationsTreeNode: rootLocalisationGroup,
                                                                                                                        resourceBundleLocationKind: resourceBundleLocationKind,
                                                                                                                        formattingConfigurationFileURL: formattingConfigurationFileURL).swiftSource)
        
        /*
         Only write the output to disk if it differs from the file that is
         already on disk. This is to prevent the file from being overwritten
         without changes, which would cause Xcode to do unnecessary compilation.
         */
        var shouldWrite = true
        if let existingContents = try? String(contentsOf: outputPathURL) {
            shouldWrite = outputString != existingContents
        }

        if shouldWrite {
            do {
                try FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true)
                try outputString.write(to: outputPathURL, atomically: true, encoding: .utf8)
            } catch {
                fputs(error.localizedDescription.cString(using: .utf8), stderr)
            }
        }
    }
}
