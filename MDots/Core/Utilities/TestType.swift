//
//  TestType.swift
//  MDots
//
//  Created by Estela Alvarez on 24/4/24.
//

import Foundation

/// An enumeration representing different types of tests.
///
/// The `TestType` enum conforms to the `String` and `CaseIterable` protocols, providing string raw values for each
/// test type and allowing iteration over all cases.
enum TestType: String, CaseIterable {
    case isquio = "Sit and Reach"
    case lunge = "Lunge"
    case hiprot = "Hip Rotation"
}
