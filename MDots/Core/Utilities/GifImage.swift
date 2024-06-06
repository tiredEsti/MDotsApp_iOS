//
//  GifImage.swift
//  MDots
//
//  Created by Estela Alvarez on 17/4/24.
//

import Foundation
import SwiftUI
import WebKit


/// A view that displays a GIF image using a `WKWebView`.
///
/// This struct conforms to the `UIViewRepresentable` protocol, allowing it to be used as a SwiftUI view.
/// It supports both light and dark mode by appending "Dark" to the image name when in dark mode.
struct GifImage: UIViewRepresentable {
    private var name: String
    @Environment(\.colorScheme) private var colorScheme

    /// Initializes a `GifImage` view with the specified image name.
    ///
    /// - Parameter name: The name of the GIF image file (without the extension).
    init(_ name: String) {
        self.name = name
    }

    /// Creates and configures the `WKWebView` to display the GIF image.
    ///
    /// - Parameter context: The context for coordinating with the SwiftUI view.
    /// - Returns: A configured `WKWebView` instance.
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false // Set the web view's background to transparent
        webView.backgroundColor = UIColor.clear // Set the background color to clear

        var imageName = name
        if colorScheme == .dark {
            // Append "Dark" to the image name if in dark mode
            imageName += "Dark"
        }
        
        let url = Bundle.main.url(forResource: imageName, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        webView.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: url.deletingLastPathComponent()
        )
        webView.scrollView.isScrollEnabled = false

        return webView
    }

    /// Updates the `WKWebView` when the SwiftUI view's state changes.
    ///
    /// - Parameters:
    ///   - uiView: The `WKWebView` instance to update.
    ///   - context: The context for coordinating with the SwiftUI view.
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

}
