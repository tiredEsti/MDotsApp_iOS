//
//  PageView.swift
//  MDots
//
//  Created by Estela Alvarez on 28/4/24.
//

import Foundation
import SwiftUI

/// A view that displays a single page with an image and a description.
///
/// ```swift
/// let page = Page(imageURL: "example.gif", description: "Sample Description")
/// PageView(page: page)
/// ```
///
/// - Parameters:
///     - page: The page data to display, including image URL and description.
struct PageView: View {
    var page: Page
    
    var body: some View {
        VStack(spacing: 10) {
            GifImage(page.imageURL)
                .scaledToFit()
                .padding()
            
            Text(page.description)
                .font(.subheadline)
                .frame(width: 300)
        }
    }
}



