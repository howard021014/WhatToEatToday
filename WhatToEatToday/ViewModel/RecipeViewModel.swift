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
    
    private var cancellables = Set<AnyCancellable>()
    let coreDatatService: CoreDataService
    
    init(_ coreDataService: CoreDataService) {
        self.coreDatatService = coreDataService
    }
    
    func fetchRecipes() {
        state = .loading
        coreDatatService.fetchRecipes()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] recipes in
                self?.state = .success(recipes)
            }
            .store(in: &cancellables)
    }
    
    func addRecipe(name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        coreDatatService.addRecipe(name: name, ingredients: ingredients, image: image?.pngData(), notes: notes)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] _ in
                self?.fetchRecipes()
            }
            .store(in: &cancellables)
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        coreDatatService.delete(recipe: recipe)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] _ in
                self?.fetchRecipes()
            }
            .store(in: &cancellables)
    }
}
