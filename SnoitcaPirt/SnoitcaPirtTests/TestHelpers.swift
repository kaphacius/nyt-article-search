//
//  TestHelpers.swift
//  SnoitcaPirtTests
//
//  Created by Yurii Zadoianchuk on 23/01/2021.
//

import XCTest
import Combine
@testable import SnoitcaPirt

class MockNetwork: Network {
    var resources: Array<Resource> = []
    var numberOfRequests: Int { resources.count }
    var lastResource: Resource? { resources.last }
    var responses: Array<Decodable> = []

    init(responses: Array<Decodable>) {
        self.responses = responses
        super.init(host: URL(string: "localhost")!)
    }

    override func load<T>(resource r: Resource) -> NPublisher<T> where T : Decodable {
        resources.append(r)
        return NJust<T>(.success(self.responses[self.resources.count - 1] as! T))
                .eraseToAnyPublisher()
    }
}

extension XCTest {
    func expectToEventually(
        _ test: @autoclosure () -> Bool,
        timeout: TimeInterval = 1.0,
        message: String = String()) {
        let runLoop = RunLoop.main
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
        repeat {
            if test() {
                return
            }
            runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        } while Date().compare(timeoutDate) == .orderedAscending

        XCTFail(message)
    }
}
