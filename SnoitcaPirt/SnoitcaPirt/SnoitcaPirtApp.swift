//
//  SnoitcaPirtApp.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import SwiftUI

@main
struct SnoitcaPirtApp: App {
    let network: Network = {
        let url = URL(string: "api.nytimes.com")!
        #error("Insert your API ket here. Can be obtained at https://developer.nytimes.com/my-apps")
        let auth = URLQueryItem(name: "api-key", value: <#T##String#>)
        let nytNetwork = Network(host: url, scheme: .https, staticQuery: [auth])

        return nytNetwork
    }()

    var body: some Scene {
        WindowGroup {
            ArticleList(
                vm: ArticleListVM(
                    dataSource: Articles(network: network)
                )
            )
        }
    }
}
