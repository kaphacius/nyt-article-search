//
//  ArticleList.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI

struct ArticleList: View {
    @ObservedObject var vm: ArticleListVM
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State var selectedIdx: String? = nil

    var body: some View {
        NavigationView {
            List {
                SearchBar(searchString: $vm.query)
                ForEach(vm.articles) { article in
                    NavigationLink(
                        destination: Text(article.headline),
                        tag: article.id,
                        selection: $selectedIdx
                    ) {
                        Text(article.headline)
                    }.onAppear(perform: {
                        vm.loadNextIfNeeded(for: article)
                    })
                }
                if vm.isLoading {
                    loadingIndicator
                }
            }
            .animation(.none)
            .navigationTitle("New York Times article search")
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    var loadingIndicator: some View {
        HStack(alignment: .center) {
            Spacer()
            Text("Loading results")
                .font(.title2)
                .padding(.trailing)
            ProgressView().progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }
}

#if DEBUG
struct ArticleList_Previews: PreviewProvider {
    static let vm: ArticleListVM = {
        let vm = ArticleListVM(dataSource: Articles(network: Network(host: URL(string: "localhost")!)))
        vm.query = "elections"
        vm.articles = [
            ArticleVM(article: Article(headline: "Headline", webUrl: String(), thumbnailUrl: nil)),
            ArticleVM(article: Article(headline: "Longer Headline", webUrl: String(), thumbnailUrl: nil)),
            ArticleVM(article: Article(headline: "Super Long Headline", webUrl: String(), thumbnailUrl: nil))
        ]
        return vm
    }()

    static var previews: some View {
        Group {
            ArticleList(vm: vm)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            ArticleList(vm: vm)
                .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            ArticleList(vm: vm)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro"))
        }

    }
}
#endif
