//
//  TestHelpers.swift
//  SnoitcaPirtTests
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import XCTest
import Combine
@testable import SnoitcaPirt

class MockNetwork: Network {
    var resources: Array<Resource> = []
    var numberOfRequests: Int { resources.count }
    var lastResource: Resource? { resources.last }
    var responses: Array<Decodable> = []

    init(responses: Array<Decodable>) {
        self.responses = responses
        super.init(host: URL(string: "localhost")!)
    }

    override func load<T>(resource r: Resource) -> NPublisher<T> where T : Decodable {
        resources.append(r)
        return NJust<T>(.success(self.responses[self.resources.count - 1] as! T))
                .eraseToAnyPublisher()
    }
}

class MockArticles: Articles {
    var lastQuery: String? = nil
    var responses = [[Article]]()
    var requestNumber = 0

    init(responses: [[Article]]) {
        self.responses = responses
        super.init(network: MockNetwork(responses: []))
    }

    override func searchArticles(with query: String) -> NPublisher<Array<Article>> {
        lastQuery = query
        let response = responses[requestNumber]
        requestNumber += 1

        return Just(.success(response)).eraseToAnyPublisher()
    }

    override func loadNextPage() -> NPublisher<Array<Article>> {
        let response = responses[requestNumber]
        requestNumber += 1

        return Just(.success(response)).eraseToAnyPublisher()
    }
}

class MockImages: Images {
    init() {
        super.init(baseUrl: URL(string: "localhost")!)
    }

    override subscript(key: String) -> UIImage? { UIImage() }
    override func loadImage(at path: String, for id: String) { }
}

extension XCTest {
    func expectToEventually(
        _ test: @autoclosure () -> Bool,
        timeout: TimeInterval = 1.0,
        message: String = String()) {
        let runLoop = RunLoop.main
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
        repeat {
            if test() {
                return
            }
            runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        } while Date().compare(timeoutDate) == .orderedAscending

        XCTFail(message)
    }
}

func articlesResponse(hits: Int = 0, offset: Int = 0) -> NYTResponse<Article> {
    return NYTResponse<Article>(
        status: "200",
        copyright: "foo",
        response: NYTResponse.Response(
            docs: [mockArticle, mockArticle, mockArticle],
            meta: NYTResponse.Response.Meta(hits: hits, offset: offset)
        )
    )
}

var mockArticle: Article {
    Article(headline: "foo", webUrl: "bar", leadParagraph: "paragraph", thumbnailUrl: "baz")
}
