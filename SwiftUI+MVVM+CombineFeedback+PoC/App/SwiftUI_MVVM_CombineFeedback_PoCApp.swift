//
//  SwiftUI_MVVM_CombineFeedback_PoCApp.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 31.03.2023..
//

import SwiftUI

@main
struct SwiftUI_MVVM_CombineFeedback_PoCApp: App {
    var body: some Scene {
        WindowGroup {
            DogListView(viewModel: DogListViewModel())
        }
    }
}
