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

@MainActor
class RecipeViewModel: ObservableObject {
    @Published private(set) var state: State = .idle

    let service: CoreDataService
    init(service: CoreDataService) {
        self.service = service
    }
    
    func fetchRecipes() {
        state = .loading
        Task {
            do {
                let recipes = try await service.fetchRecipes()
                state = .success(recipes)
            } catch {
                state = .failure(error)
            }
        }
    }
    
    func addRecipe(
        name: String,
        ingredients: [IngredientData],
        image: UIImage?,
        notes: String?
    ) {
        Task {
            do {
                try await service.addRecipe(
                    name: name,
                    ingredients: ingredients,
                    image: image?.pngData(), 
                    notes: notes
                )
                
                let updated = try await service.fetchRecipes()
                state = .success(updated)
            } catch {
                state = .failure(error)
            }
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        Task {
            do {
                try await service.delete(recipe: recipe)
                let updated = try await service.fetchRecipes()
                state = .success(updated)
            } catch {
                state = .failure(error)
            }
        }
    }
    
    func updateRecipe(
        _ recipe: Recipe,
        name: String,
        ingredients: [IngredientData],
        image: UIImage?,
        notes: String?
    ) {
        Task {
            do {
                try await service.update(
                    recipe: recipe,
                    name: name,
                    ingredients: ingredients,
                    image: image?.pngData(),
                    notes: notes
                )
                
                let updated = try await service.fetchRecipes()
                state = .success(updated)
            } catch {
                state = .failure(error)
            }
        }
    }
}
