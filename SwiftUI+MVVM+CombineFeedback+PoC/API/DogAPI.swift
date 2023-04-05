//
//  DogAPI.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 31.03.2023..
//

import Foundation
import Combine

protocol DogAPIType {
    static func getDogList() -> AnyPublisher<DogListResponse, Error>
    static func getDogDetails(name: String) -> AnyPublisher<DogDetailsResponse, Error>
}

class DogAPI: DogAPIType {
    private struct Constants {
        static let baseUrl = "https://dog.ceo/api/breed"
        static let dogListPath = "s/list/all"
        static let dogDetailPath = "images/random/5"
    }

    private static let agent = Agent()

    static func getDogList() -> AnyPublisher<DogListResponse, Error> {
        let urlString = Constants.baseUrl + Constants.dogListPath
        let urlRequest = URL(string: urlString)
            .map { URLRequest.init(url: $0) }

        if let urlRequest = urlRequest {
            return agent.run(urlRequest)
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    static func getDogDetails(name: String) -> AnyPublisher<DogDetailsResponse, Error> {
        let urlString = Constants.baseUrl + "/" + name + "/" + Constants.dogDetailPath
        let urlRequest = URL(string: urlString)
            .map { URLRequest.init(url: $0) }

        if let urlRequest = urlRequest {
            return agent.run(urlRequest)
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}
