//
//  RecipeFormViewModel.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-05-01.
//

import Combine
import UIKit
import Foundation

enum RecipeFormMode: Equatable {
    case create
    case edit(existing: Recipe)
}

class RecipeDraft: ObservableObject {
    var recipeImage: UIImage? = nil
    var recipeName: String = ""
    var ingredients: [IngredientData] = []
    var recipeNotes: String? = nil
    
    init(recipeImage: UIImage? = nil, recipeName: String = "", ingredients: [IngredientData] = [], recipeNotes: String? = nil) {
        self.recipeImage = recipeImage
        self.recipeName = recipeName
        self.ingredients = ingredients
        self.recipeNotes = recipeNotes
    }
    
    func copy() -> RecipeDraft {
        RecipeDraft(
            recipeImage: self.recipeImage,
            recipeName: self.recipeName,
            ingredients: self.ingredients,
            recipeNotes: self.recipeNotes
        )
    }
}

class RecipeFormViewModel {
    @Published private(set) var state: State<[Recipe]> = .idle
    @Published private(set) var isEditable: Bool = true
    
    let mode: RecipeFormMode
    var draft: RecipeDraft
    private let store: RecipeStore
    private var cancellables = Set<AnyCancellable>()
    
    private var originalDraft: RecipeDraft?
    
    init(mode: RecipeFormMode, store: RecipeStore) {
        self.mode = mode
        self.store = store
        switch mode {
        case .create:
            isEditable = true
            self.draft = RecipeDraft()
        case .edit(let recipe):
            isEditable = false
            let loaded = RecipeDraft(
                recipeImage: UIImage(data: recipe.image ?? Data()),
                recipeName: recipe.name ?? "",
                ingredients: (recipe.ingredients?.array as? [Ingredient])?.map {
                    IngredientData(name: $0.name ?? "", unit: $0.unit ?? "")
                } ?? [],
                recipeNotes: recipe.notes ?? ""
            )
            self.draft = loaded
            self.originalDraft = draft.copy()
        }
    }
    
    func saveOrUpdate() {
        switch mode {
        case .create:
            store.addRecipe(name: draft.recipeName,
                            ingredients: draft.ingredients,
                            image: draft.recipeImage,
                            notes: draft.recipeNotes)
        case .edit(let recipe):
            store.updateRecipe(recipe,
                               name: draft.recipeName,
                               ingredients: draft.ingredients,
                               image: draft.recipeImage,
                               notes: draft.recipeNotes)
        }
    }
    
    func cancelEdit() {
        if case .edit = mode, let originalDraft {
            draft.recipeImage = originalDraft.recipeImage
            draft.recipeName = originalDraft.recipeName
            draft.ingredients = originalDraft.ingredients
            draft.recipeNotes = originalDraft.recipeNotes
            isEditable = false
        }
    }

    func updateRecipe(_ recipe: Recipe, name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        store.updateRecipe(recipe, name: name, ingredients: ingredients, image: image, notes: notes)
    }
    
    func addRecipe(name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        store.addRecipe(name: name, ingredients: ingredients, image: image, notes: notes)
    }
    
    func toggleEditing() {
        isEditable.toggle()
    }
}
