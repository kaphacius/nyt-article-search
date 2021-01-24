//
//  ArticleListVMTests.swift
//  SnoitcaPirtTests
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import XCTest
@testable import SnoitcaPirt

class ArticleListVMTests: XCTestCase {
    var ma: MockArticles!
    var mi: MockImages!
    var query: String!

    override func setUpWithError() throws {
        ma = MockArticles(
            responses: Array(
                repeating: [mockArticle, mockArticle, mockArticle, mockArticle, mockArticle], count: 5
            )
        )

        mi = MockImages()

        query = "query"
    }

    override func tearDownWithError() throws {

    }

    func testSimpleSearch() {
        let sut = ArticleListVM(dataSource: ma, images: mi)
        sut.query = query

        expectToEventually(
            ma.requestNumber == 1,
            timeout: 1.0
        )

        XCTAssert(ma.lastQuery == query, "Wrong query string")
    }

    func testInputSearch() {
        let sut = ArticleListVM(dataSource: ma, images: mi)
        sut.query = String(query.prefix(1))
        sut.query = String(query.prefix(2))
        sut.query = String(query.prefix(3))

        expectToEventually(
            ma.requestNumber == 1,
            timeout: 1.0
        )

        XCTAssert(ma.lastQuery == String(query.prefix(3)), "Wrong number of requests during continous input")

        sut.query = query

        expectToEventually(
            ma.requestNumber == 2,
            timeout: 1.0
        )

        XCTAssert(ma.lastQuery == query, "Wrong query string")
    }

    func testRequestNextPage() {
        let sut = ArticleListVM(dataSource: ma, images: mi)
        sut.query = query

        expectToEventually(
            ma.requestNumber == 1,
            timeout: 1.0
        )

        sut.loadNextIfNeeded(for: sut.articles[0])

        XCTAssertFalse(sut.isLoading, "Loading next page too early")

        sut.loadNextIfNeeded(for: sut.articles[sut.articles.count - ArticleListVM.nextPageMargin])

        XCTAssertTrue(sut.isLoading, "Did not start loading next page")

        expectToEventually(
            ma.requestNumber == 2,
            timeout: 1.0
        )
    }
}
