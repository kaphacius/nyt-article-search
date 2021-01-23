//
//  NYTResponse.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation

struct NYTResponse<T: Decodable>: Decodable {
    let status: String
    let copyright: String
    let response: Response

    struct Response: Decodable {
        let docs: Array<T>
        let meta: Meta

        struct Meta: Decodable {
            let hits: Int
            let offset: Int
        }
    }
}
