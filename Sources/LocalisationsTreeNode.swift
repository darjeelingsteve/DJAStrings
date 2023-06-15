//
//  LocalisationsTreeNode.swift
//  
//
//  Created by Stephen Anthony on 15/06/2023.
//

import Foundation

/// The protocol to conform to when providing the behaviour of a node in a
/// localisations tree.
protocol LocalisationsTreeNode {
    
    /// The node's name.
    var name: String { get }
    
    /// The localisations that are direct descendants of the node.
    var localisations: [Localisation] { get }
    
    /// The children of the node.
    var childNodes: [Self] { get }
}
