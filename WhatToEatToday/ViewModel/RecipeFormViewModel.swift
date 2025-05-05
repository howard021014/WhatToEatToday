//
//  RecipeFormViewModel.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-05-01.
//

import Combine
import UIKit
import Foundation

class RecipeFormViewModel {
    @Published private(set) var state: State<[Recipe]> = .idle
    
    private let store: RecipeStore
    private var cancellables = Set<AnyCancellable>()
    
    init(store: RecipeStore) {
        self.store = store
    }

    func updateRecipe(_ recipe: Recipe, name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        store.updateRecipe(recipe, name: name, ingredients: ingredients, image: image, notes: notes)
    }
    
    func addRecipe(name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        store.addRecipe(name: name, ingredients: ingredients, image: image, notes: notes)
    }
    
    
}
