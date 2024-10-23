//
//  RecipeListViewModel.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-06-25.
//

import UIKit
import Combine

enum State {
    case idle
    case loading
    case success([Recipe])
    case failure(Error)
}

class RecipeViewModel {
    @Published private(set) var state: State = .idle
    
    func fetchRecipes() {
        state = .loading
        CoreDataManager.shared.fetchRecipes { result in
            switch result {
            case .success(let recipes):
                DispatchQueue.main.async { [weak self] in
                    self?.state = .success(recipes)
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.state = .failure(error)
                }
            }
        }
    }
    
    func addRecipe(name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        CoreDataManager.shared.saveRecipe(name: name, ingredients: ingredients, image: image?.pngData(), notes: notes)
    }
    
    func addSampleRecipes()  {
        CoreDataManager.shared.generateDummyData()
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        CoreDataManager.shared.deleteRecipe(recipe)
    }
}
