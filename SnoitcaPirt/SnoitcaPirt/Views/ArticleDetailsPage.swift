//
//  ArticleDetailsPage.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI
import WebKit

struct ArticleDetailsPage: View {
    let vm: ArticleVM
    var body: some View {
        VStack {
            WebViewWrapper(url: vm.url)
        }
        .navigationBarTitle("Article details")
        .navigationBarItems(
            trailing:
                Button(action: onShare, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                    }
                })
        )
    }

    func onShare() {

    }
}

final class WebViewWrapper: NSObject, UIViewRepresentable {
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(
        _ webView: WKWebView,
        context: UIViewRepresentableContext<WebViewWrapper>
    ) {
        _ = url
            .map { URLRequest(url: $0) }
            .map(webView.load)
    }
}
