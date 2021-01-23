//
//  ArticleDetailsPage.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI

struct ArticleDetailsPage: View {
    @State var presentingShareSheet: Bool = false

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
                }).sheet(
                    isPresented: $presentingShareSheet,
                    content: {
                        ActivityView(toShare: vm.url)
                    }
                )
        )
    }

    func onShare() {
        presentingShareSheet = true
    }
}
