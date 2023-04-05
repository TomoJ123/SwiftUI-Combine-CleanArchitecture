//
//  DogDetailsView.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 01.04.2023..
//

import SwiftUI
import Kingfisher

struct DogDetailsView: View {
    @StateObject var viewModel: DogDetailsViewModel
    let subBreed: [String]

    var body: some View {
        GeometryReader { proxy in
            VStack {
                image
                    .frame(width: proxy.size.width * 0.8, height: proxy.size.height / 2, alignment: .top)
                    .clipShape(Circle())

                Spacer()

                list(of: subBreed)
            }
        }
        .onAppear { viewModel.send(event: .onAppear) }
    }

    private var image: some View {
        switch viewModel.state {
        case .idle, .loading, .error:
            return EmptyView().eraseToAnyView()
        case .loaded(let url):
            return KFImage(url)
                .resizable()
                .eraseToAnyView()
        }
    }

    private func list(of subBreed: [String]) -> some View {
        return List(subBreed, id: \.self) { breed in
            Text(breed.capitalizingFirstLetter())
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden)
    }
}

struct DogDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DogDetailsView(viewModel: DogDetailsViewModel(dogName: "Tiko"), subBreed: ["Koko", "Luna"])
    }
}
