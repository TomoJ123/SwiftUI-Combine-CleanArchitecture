//
//  DogDetailsViewModel.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 01.04.2023..
//

import Foundation
import Combine

class DogDetailsViewModel: ObservableObject {
    @Published private(set) var state: State

    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()

    init(dogName: String) {
        state = .idle(dogName: dogName)

        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [
                            Self.userInput(input: input.eraseToAnyPublisher()),
                            Self.whenLoading()
                          ])
        .assignNoRetain(to: \.state, on: self)
        .store(in: &bag)
    }

    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types
extension DogDetailsViewModel {
    enum State {
        case idle(dogName: String)
        case loading(dogName: String)
        case loaded(URL)
        case error(String)
    }

    enum Event {
        case onAppear
        case onDogDetailsLoaded(DogDetails)
        case onFailedToLoad(Error)
    }
}

// MARK: State Machine

extension DogDetailsViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle(dogName: let name):
            switch event {
            case .onAppear:
                return .loading(dogName: name)
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFailedToLoad(let error):
                return .error(error.localizedDescription)
            case .onDogDetailsLoaded(let details):
                if let url = URL(string: details.images.first ?? "") {
                    return .loaded(url)
                } else {
                    return .error("Failed to load image!")
                }
            default:
                return state
            }
        default:
            return state
        }
    }

    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading(let name) = state else { return Empty().eraseToAnyPublisher() }

            return DogAPI.getDogDetails(name: name)
                .map { $0.toDogDetails() }
                .map (Event.onDogDetailsLoaded)
                .catch { Just(Event.onFailedToLoad($0)) }
                .eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback(run: { _ in
            return input
        })
    }
}
