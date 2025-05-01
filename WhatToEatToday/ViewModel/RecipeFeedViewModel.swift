//
//  RecipeFeedViewModel.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-04-30.
//

import Combine
import Foundation

class RecipeFeedViewModel {
    @Published var state: State<[Recipe]> = .idle
    
    let service: CoreDataService
    var cancellables = Set<AnyCancellable>()

    init(coreDataService: CoreDataService = DIContainer.shared.coreDataService) {
        self.service = coreDataService
    }
    
    func fetchRecipes() {
        service.fetchRecipes()
            .map(State.success)
            .prepend(.loading)
            .catch { Just(State.failure($0)) }
            .receive(on: RunLoop.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
}
