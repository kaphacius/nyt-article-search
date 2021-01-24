//
//  Images.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation
import UIKit
import Combine

class Images: ObservableObject {
    private var cache: Dictionary<String, UIImage> = [:]

    subscript(key: String) -> UIImage? {
        cache[key]
    }

    private let baseUrl: URL
    private let scheme: Network.Scheme
    private var cancellables: Set<AnyCancellable> = []

    let imageLoadSubject = PassthroughSubject<(String, UIImage), Never>()

    init(baseUrl: URL, scheme: Network.Scheme = .https) {
        self.baseUrl = baseUrl
        self.scheme = scheme
    }

    func loadImage(at path: String, for id: String) {
        var comps = URLComponents()
        comps.host = baseUrl.absoluteString
        comps.path = path.prefix(1) == "/" ? path : "/\(path)"
        comps.scheme = scheme.rawValue

        guard let url = comps.url else { return }

        URLSession
            .shared
            .dataTaskPublisher(for: URLRequest(url: url))
            .map(\.data)
            .compactMap(UIImage.init)
            .map(Result.success)
            .catch({ Just(.failure(NError.URLError($0))).eraseToAnyPublisher() })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let img):
                    self?.cache[id] = img
                    self?.imageLoadSubject.send((id, img))
                case .failure(_):
                    break
                }
            })
            .store(in: &cancellables)
    }
}
