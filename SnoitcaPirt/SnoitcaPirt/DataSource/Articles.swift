//
//  Articles.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation
import Combine

class Articles {
    internal static let articlesPerPage = 10

    private var cancellables: Set<AnyCancellable> = []
    private let network: Network
    private var lastQuery: String? = nil
    private var lastResponse: NYTResponse<Article>? = nil

    init(network: Network) {
        self.network = network
    }

    func searchArticles(with query: String) -> NPublisher<Array<Article>> {
        lastQuery = query
        return loadResource(ArticleSearchResource(page: 0, query: query))
    }

    func loadNextPage() -> NPublisher<Array<Article>> {
        guard let lq = lastQuery,
              hasNextPage else {
            return Just(.success([])).eraseToAnyPublisher()
        }

        return loadResource(ArticleSearchResource(page: currentPage + 1, query: lq))
    }

    private func loadResource(_ r: Resource) -> NPublisher<Array<Article>> {
        network.load(resource: r)
            .compactMap({ [weak self] in self?.processResponse(result: $0) })
            .eraseToAnyPublisher()
    }

    private func processResponse(
        result: NResult<NYTResponse<Article>>
    ) -> NResult<[Article]> {
        result.map({ success in
            lastResponse = success
            return success.response.docs
        })
    }

    var hasNextPage: Bool {
        lastResponse
            .map(\.response.meta)
            .map({ meta in meta.hits > meta.offset + Articles.articlesPerPage }) ?? false
    }

    private var currentPage: Int {
        lastResponse
            .map(\.response.meta)
            .map({ meta in meta.offset / Articles.articlesPerPage }) ?? 0
    }
}
