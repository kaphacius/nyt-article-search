//
//  ArticleList.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI

struct ArticleList: View {
    static let rowHeight: CGFloat = 80.0

    @ObservedObject var vm: ArticleListVM
    @State var selectedIdx: String? = nil

    var body: some View {
        NavigationView {
            List {
                SearchBar(searchString: $vm.query)
                articleList
                if vm.isLoading {
                    loadingIndicator
                        .frame(height: ArticleList.rowHeight)
                }
            }
            .animation(.none)
            .navigationTitle("New York Times")
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    var loadingIndicator: some View {
        HStack(alignment: .center) {
            Spacer()
            Text("Loading results")
                .font(.title)
                .padding(.trailing)
            ProgressView().progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
    }

    var articleList: some View {
        ForEach(vm.articles) { article in
            NavigationLink(
                destination: ArticleDetailsPage(vm: article),
                tag: article.id,
                selection: $selectedIdx
            ) {
                ArticleListElement(vm: binding(for: article))
                    .frame(height: ArticleList.rowHeight)
            }.onAppear(perform: {
                vm.loadNextIfNeeded(for: article)
            })
        }
    }

    private func binding(for article: ArticleVM) -> Binding<ArticleVM> {
        let idx = vm.articles.firstIndex(where: { $0.id == article.id })!
        return $vm.articles[idx]
    }
}

#if DEBUG
struct ArticleList_Previews: PreviewProvider {
    static let vm: ArticleListVM = {
        let vm = ArticleListVM(
            dataSource: Articles(network: Network(host: URL(string: "localhost")!)),
            images: Images(baseUrl: URL(string: "localhost")!)
        )
        vm.query = "elections"
        vm.articles = [
            ArticleVM(article: Article(headline: "Headline", webUrl: "localhost", leadParagraph: "Paragraph", thumbnailUrl: "localhost")),
            ArticleVM(article: Article(headline: "Longer Headline", webUrl: "localhost", leadParagraph: "Paragraph", thumbnailUrl: "localhost")),
            ArticleVM(article: Article(headline: "Super Long Headline", webUrl: "localhost", leadParagraph: "Paragraph", thumbnailUrl: "localhost"))
        ].compactMap({ $0 })
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
