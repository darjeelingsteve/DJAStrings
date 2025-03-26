//
//  ResourceBundleLocationKind.swift
//  DJAStrings
//
//  Created by Stephen Anthony on 26/03/2025.
//

import Foundation
import ArgumentParser

/// The different resource bundle locations supported by DJAStrings.
enum ResourceBundleLocationKind: String, ExpressibleByArgument {
    /// For use when the localised assets that the generated code refers to will
    /// be located within a framework or application target.
    case standard
    
    /// For use when the localised assets that the generated code refers to will
    /// be located within a Swift Package resource bundle e.g
    /// `ModuleName.bundle`.
    case swiftPackage = "swift-package"
}
