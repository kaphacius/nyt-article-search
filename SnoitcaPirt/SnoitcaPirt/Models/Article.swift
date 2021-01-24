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
        case leadParagraph = "lead_paragraph"
    }

    let headline: String
    let leadParagraph: String
    let webUrl: String
    let thumbnailUrl: String?
    let id: String

    internal init(
        headline: String,
        webUrl: String,
        leadParagraph: String,
        thumbnailUrl: String?,
        id: String = UUID().uuidString
    ) {
        self.headline = headline
        self.leadParagraph = leadParagraph
        self.webUrl = webUrl
        self.thumbnailUrl = thumbnailUrl
        self.id = id
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        webUrl = try c.decode(String.self, forKey: .webUrl)
        leadParagraph = try c.decode(String.self, forKey: .leadParagraph)

        let headlineC = try c.nestedContainer(keyedBy: CodingKeys.self, forKey: .headline)
        headline = try headlineC.decode(String.self, forKey: .main)

        let multimedia = try c.decode([Multimedia].self, forKey: .multimedia)
        thumbnailUrl = multimedia
            .first(where: {
                $0.type == Multimedia.imageType
                    && $0.subtype == Multimedia.thumbnailSubtype
            })
            .map(\.url)
    }
}

extension Article {
    struct Multimedia: Decodable {
        static let imageType = "image"
        static let thumbnailSubtype = "thumbnail"

        let type: String
        let subtype: String
        let url: String
    }
}
