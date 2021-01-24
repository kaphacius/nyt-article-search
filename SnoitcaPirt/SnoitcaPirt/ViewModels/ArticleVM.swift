//
//  ArticleVM.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation
import UIKit

struct ArticleVM: Identifiable, Equatable {
    let headline: String
    let leadParagraph: String
    let url: URL
    let id: String
    var img: UIImage?
    var hasThumbnail: Bool

    init?(article: Article, img: UIImage? = nil) {
        guard let url = URL(string: article.webUrl) else {
            return nil
        }

        self.headline = article.headline
        self.id = article.id
        self.url = url
        self.hasThumbnail = article.thumbnailUrl != nil
        self.img = img
        self.leadParagraph = article.leadParagraph
    }
}
