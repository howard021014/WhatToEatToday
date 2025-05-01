//
//  RecipeListViewModel.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-04-30.
//

import Combine
import Foundation

class RecipeListViewModel: RecipeFeedViewModel {

    func deleteRecipe(_ recipe: Recipe) {
        service.delete(recipe: recipe)
            .flatMap { [unowned self] in self.service.fetchRecipes() }
            .map(State.success)
            .catch { Just(State.failure($0)) }
            .receive(on: RunLoop.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
}
