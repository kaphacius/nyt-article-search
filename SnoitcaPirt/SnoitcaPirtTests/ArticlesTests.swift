//
//  ArticlesTests.swift
//  SnoitcaPirtTests
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import XCTest
@testable import SnoitcaPirt

class ArticlesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleSearch() {
        let mn = MockNetwork(responses: [
            articlesResponse()
        ])

        let q = "query"
        let sut = Articles(network: mn)
        _ = sut.searchArticles(with: q).sink(receiveValue: { _ in })

        expectToEventually(
            mn.resources.isEmpty == false,
            timeout: 1.0
        )

        guard let resource = mn.lastResource.flatMap({ $0 as? ArticleSearchResource }) else {
            XCTAssert(false, "Search failed in \(#function)")
            return
        }

        XCTAssert(resource.query == q, "Wrong search query")
        XCTAssert(resource.page == 0, "Wrong search page")
    }

    func testNoNextPage() {
        let mn = MockNetwork(responses: [
            articlesResponse(hits: Articles.articlesPerPage, offset: 0)
        ])

        let q = "query"
        let sut = Articles(network: mn)
        _ = sut.searchArticles(with: q).sink(receiveValue: { _ in })

        expectToEventually(
            mn.resources.isEmpty == false,
            timeout: 1.0
        )

        XCTAssert(sut.hasNextPage == false, "SUT should not have next page")
    }

    func testLoadNextPage() {
        let mn = MockNetwork(responses: [
            articlesResponse(hits: 100, offset: 0),
            articlesResponse(hits: 100, offset: 10)
        ])

        let q = "query"
        let sut = Articles(network: mn)
        _ = sut.searchArticles(with: q).sink(receiveValue: { _ in })

        expectToEventually(
            mn.resources.count == 1,
            timeout: 1.0
        )

        _ = sut.loadNextPage().sink(receiveValue: { _ in })

        expectToEventually(
            mn.resources.count == 2,
            timeout: 1.0
        )

        guard let resource = mn.lastResource.flatMap({ $0 as? ArticleSearchResource }) else {
            XCTAssert(false, "Search failed in \(#function)")
            return
        }

        XCTAssert(resource.query == q, "Wrong search query")
        XCTAssert(resource.page == 1, "Wrong search page")
    }

    func articlesResponse(hits: Int = 0, offset: Int = 0) -> NYTResponse<Article> {
        return NYTResponse<Article>(
            status: "200",
            copyright: "foo",
            response: NYTResponse.Response(
                docs: [mockArticle(), mockArticle(), mockArticle()],
                meta: NYTResponse.Response.Meta(hits: hits, offset: offset)
            )
        )
    }

    func mockArticle() -> Article {
        Article(headline: "foo", webUrl: "bar", thumbnailUrl: "baz")
    }
}
