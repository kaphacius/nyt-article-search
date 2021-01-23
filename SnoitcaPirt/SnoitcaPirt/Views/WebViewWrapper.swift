//
//  WebViewWrapper.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation
import SwiftUI
import WebKit

final class WebViewWrapper: NSObject, UIViewRepresentable {
    private let url: URL
    private var loaded: Bool = false

    init(url: URL) {
        self.url = url
    }

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(
        _ webView: WKWebView,
        context: UIViewRepresentableContext<WebViewWrapper>
    ) {
        guard loaded == false else { return }
        webView.load(URLRequest(url: url))
        loaded = true
    }
}
