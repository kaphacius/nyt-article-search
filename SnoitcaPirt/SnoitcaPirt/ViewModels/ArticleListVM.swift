//
//  ArticleListVM.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI
import Combine

struct ArticleVM: Identifiable, Equatable {
    let headline: String
    let url: URL
    let id: String

    init?(article: Article) {
        guard let url = URL(string: article.webUrl) else {
            return nil
        }

        self.headline = article.headline
        self.id = article.id
        self.url = url
    }
}

class ArticleListVM: ObservableObject {
    static let nextPageMargin: Int = 3

    @Published var articles: Array<ArticleVM> = []
    @Published var isLoading: Bool = false
    @Published var query: String = String()
    @Published var errorMessage: String? = nil

    private let ds: Articles
    private var cancellables: Set<AnyCancellable> = []
    private var isLoadingNextPage: Bool = false
    private let loadingSubject = PassthroughSubject<SubjectInput, Never>()

    init(dataSource ds: Articles) {
        self.ds = ds

        setUpSearch()
    }

    func setUpSearch() {
        $query
            .subscribe(on: DispatchQueue.global())
            .filter({ $0.count > 2 })
            .debounce(for: 0.2, scheduler: DispatchQueue.global())
            .removeDuplicates()
            .sink(receiveValue: { [weak self] q in
                self?.loadingSubject.send(SubjectInput(query: q, nextPage: false))
            }).store(in: &cancellables)

        loadingSubject
            .receive(on: DispatchQueue.main)
            .flatMap(maxPublishers: .max(1), { [weak self] (input: SubjectInput) -> NPublisher<Array<Article>> in
                guard let weakSelf = self else {
                    return Just(.failure(Errors.articleLoadingError))
                        .eraseToAnyPublisher()
                }
                weakSelf.setLoadingState(input: input)
                if input.nextPage {
                    return weakSelf.ds.loadNextPage()
                } else {
                    return weakSelf.ds.searchArticles(with: input.query)
                }
            }).receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.searchResponseReceived($0) })
            .store(in: &cancellables)
    }

    func loadNextIfNeeded(for article: ArticleVM) {
        guard isLoadingNextPage == false else { return }

        let loadAt = articles.index(articles.endIndex, offsetBy: -ArticleListVM.nextPageMargin)
        if articles.firstIndex(where: { $0 == article }) == loadAt {
            isLoadingNextPage = true
            isLoading = true

            loadingSubject.send(SubjectInput(query: query, nextPage: true))
        }
    }

    private func searchResponseReceived(_ result: NResult<Array<Article>>) {
        switch result {
        case .success(let nextPage) where isLoadingNextPage:
            articles.append(contentsOf: nextPage.compactMap(ArticleVM.init))
        case .success(let new):
            articles = new.compactMap(ArticleVM.init)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }

        isLoading = false
        isLoadingNextPage = false
    }

    private func setLoadingState(input: SubjectInput) {
        isLoading = true
        isLoadingNextPage = input.nextPage
        if input.nextPage == false {
            articles = []
        }
    }
}

extension ArticleListVM {
    struct SubjectInput {
        let query: String
        let nextPage: Bool
    }
}

extension ArticleListVM {
    enum Errors: Error {
        case articleLoadingError
    }
}
