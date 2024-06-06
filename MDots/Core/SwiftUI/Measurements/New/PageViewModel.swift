//
//  PageModel.swift
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

import Foundation

/// Represents a page in the measurement setup values.
struct Page: Identifiable, Equatable {
    let id = UUID()
    var testType: TestType
    var tag: Int
    var imageURL: String
    var description: String
    
    
}

extension Page {
    /// Creates an array of `Page` objects based on the provided `TestType`.
    ///
    /// - Parameters testType: The type of test for which pages are being created.
    /// - Returns: An array of `Page` objects representing the setup pages for the given test type.
    
    static func createPages(testType: TestType) -> [Page] {
        let pages: [Page] = [
            Page(testType: testType, tag: 0, imageURL: testType.rawValue+"AngleGif", description: "Measured angle"),
            Page(testType: testType, tag: 1, imageURL: testType.rawValue+"DotPlacementGif", description: "Dot placement"),
            Page(testType: testType, tag: 2, imageURL: testType.rawValue+"DotGif", description: "Set dots vertically"),
        ]
        return pages
    }
}
