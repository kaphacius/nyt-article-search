//
//  ArticleSearchResource.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation

struct ArticleSearchResource: Resource {
    let page: Int
    let query: String

    let path = "/svc/search/v2/articlesearch.json"
    let method: Network.Method = .get

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: page.description),
            URLQueryItem(name: "q", value: query)
        ]
    }
}
