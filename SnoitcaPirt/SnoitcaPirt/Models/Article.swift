//
//  Article.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation

struct Article: Decodable {

    enum CodingKeys: String, CodingKey {
        case webUrl = "web_url"
        case headline
        case main
        case multimedia
        case id = "_id"
    }

    let headline: String
    let webUrl: String
    let thumbnailUrl: String?
    let id: String

    internal init(
        headline: String,
        webUrl: String,
        thumbnailUrl: String?,
        id: String = UUID().uuidString
    ) {
        self.headline = headline
        self.webUrl = webUrl
        self.thumbnailUrl = thumbnailUrl
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        webUrl = try c.decode(String.self, forKey: .webUrl)

        let headlineC = try c.nestedContainer(keyedBy: CodingKeys.self, forKey: .headline)
        headline = try headlineC.decode(String.self, forKey: .main)

        let multimedia = try c.decode([Multimedia].self, forKey: .multimedia)
        thumbnailUrl = multimedia
            .first(where: { $0.type == Multimedia.imageType })
            .map(\.url)
    }
}

extension Article {
    struct Multimedia: Decodable {
        static let imageType = "image"

        let type: String
        let url: String
    }
}
