//
//  RecipeStore.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-05-02.
//

import Combine
import UIKit
import Foundation

class RecipeStore {
    @Published private(set) var state: State<[Recipe]> = .idle
    
    private let service: CoreDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: CoreDataService) {
        self.service = service
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
    
    func addRecipe(name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        service.addRecipe(name: name, ingredients: ingredients, image: image?.pngData(), notes: notes)
            .flatMap{ [unowned self] in self.service.fetchRecipes() }
            .map(State.success)
            .catch { Just(State.failure($0)) }
            .receive(on: RunLoop.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        service.delete(recipe: recipe)
            .flatMap { [unowned self] in self.service.fetchRecipes() }
            .map(State.success)
            .catch { Just(State.failure($0)) }
            .receive(on: RunLoop.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
    
    func updateRecipe(_ recipe: Recipe, name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        service.update(recipe: recipe, name: name, ingredients: ingredients, image: image?.pngData(), notes: notes)
            .flatMap { [unowned self] in self.service.fetchRecipes() }
            .map(State.success)
            .catch { Just(State.failure($0)) }
            .receive(on: RunLoop.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }
}
