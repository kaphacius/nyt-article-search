//
//  Network.swift
//  SnoitcaPirt
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import Foundation
import Combine

enum Errors: Error {
    case URLError(Error)
    case parsingError
    case urlBuildFailed
}

typealias NResult<T> = Result<T, Errors>
typealias NJust<T> = Just<NResult<T>>

class Network {
    private let host: URL
    private let scheme: Scheme
    private let staticQuery: [URLQueryItem]

    init(
        host: URL,
        scheme: Scheme = .http,
        staticQuery: [URLQueryItem]
    ) {
        self.host = host
        self.scheme = scheme
        self.staticQuery = staticQuery
    }

    private func buildRequest(resource r: Resource) -> URLRequest? {
        r.buildUrlRequest(scheme: scheme, host: host.absoluteString, staticQuery: staticQuery)
    }

    func load<T>(resource r: Resource) -> AnyPublisher<NResult<T>, Never> where T : Decodable {
        guard let request = buildRequest(resource: r) else {
            return Just<NResult<T>>(.failure(.urlBuildFailed)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .map(Result.success)
            .catch { NJust<T>(.failure(.URLError($0))).eraseToAnyPublisher() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension Network {
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
    }

    enum Scheme: String {
        case http = "http"
        case https = "https"
    }
}
