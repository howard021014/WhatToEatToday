//
//  SlotMachineViewModel.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-04-30.
//

import Combine
import Foundation

class SlotMachineViewModel {
    @Published private(set) var state: State<[Recipe]> = .idle
    
    private let store: RecipeStore
    private var cancellables = Set<AnyCancellable>()
    
    init(store: RecipeStore) {
        self.store = store
        store.$state
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
    
    func fetchRecipes() {
        store.fetchRecipes()
    }
}
