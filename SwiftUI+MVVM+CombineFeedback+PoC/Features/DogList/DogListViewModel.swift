//
//  DogListViewModel.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 31.03.2023..
//

import Foundation
import Combine

class DogListViewModel: ObservableObject {
    @Published private(set) var state = State()
    @Published var searchedText: String = ""

    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()

    init() {
        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [
                            Self.whenLoading(),
                            Self.userInput(input: input.eraseToAnyPublisher())
                          ])
        .assignNoRetain(to: \.state, on: self)
        .store(in: &bag)
    }

    deinit {
        bag.removeAll()
    }

    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types
extension DogListViewModel {
    struct State {
        var viewState: ViewState = .idle
        var allItems: [DogListItem] = []
    }

    enum ViewState {
        case idle
        case loading
        case loaded([DogListItem])
        case error(Error)
    }

    enum Event {
        case onAppear
        case onDogListLoaded([DogListItem])
        case onFailedToLoad(Error)
        case searchInitiated(String)
    }
}

// MARK: - State Machine
extension DogListViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        var result = state

        switch event {
        case .onAppear:
            result.viewState = .loading
        case .onDogListLoaded(let items):
            result.allItems = items
            result.viewState = .loaded(items)
        case .onFailedToLoad(let error):
            result.viewState = .error(error)
        case .searchInitiated(let searchedTerm):
            if searchedTerm.isEmpty {
                result.viewState = .loaded(result.allItems)
            } else {
                let filteredGames = result.allItems.filter { $0.name.contains(searchedTerm) }
                result.viewState = .loaded(filteredGames)
            }
        }

        return result
    }

    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state.viewState else { return Empty().eraseToAnyPublisher() }

            return DogAPI.getDogList()
                .map { $0.dogInfo.map { DogListItem.init(name: $0.key.capitalizingFirstLetter(), subBreed: $0.value) }}
                .map(Event.onDogListLoaded)
                .catch { Just(Event.onFailedToLoad($0)) }
                .eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
