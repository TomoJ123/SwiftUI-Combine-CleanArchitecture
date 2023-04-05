//
//  DogListView.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 31.03.2023..
//

import SwiftUI

struct DogListView: View {
    @StateObject var viewModel: DogListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationBarTitle("Dog Breed")
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
        .searchable(text: $viewModel.searchedText)
        .onReceive(
            viewModel
                .$searchedText
                .dropFirst()
                .debounce(for: .seconds(1), scheduler: DispatchQueue.main)) { searchedTerm in
                    viewModel.send(event: .searchInitiated(searchedTerm))
        }
    }

    private var content: some View {
        switch viewModel.state.viewState {
        case .idle:
            return EmptyView().eraseToAnyView()
        case .loading:
            return ProgressView()
                .frame(width: 50, height: 50)
                .background { Color.gray.cornerRadius(10) }
                .eraseToAnyView()
        case .loaded(let dogs):
            return list(of: dogs).eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        }
    }

    private func list(of dogs: [DogListItem]) -> some View {
        return List(dogs, id: \.self) { dog in
            NavigationLink(destination: DogDetailsView(viewModel: DogDetailsViewModel(dogName: dog.name.decapitalizingFirstLetter()), subBreed: dog.subBreed)) {
                Text(dog.name)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DogListView(viewModel: DogListViewModel())
    }
}
