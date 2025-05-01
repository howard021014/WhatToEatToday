//
//  RecipeListViewModel.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-06-25.
//

import UIKit
import Combine

enum State<Value> {
    case idle
    case loading
    case success(Value)
    case failure(Error)
}

class RecipeViewModel {
    @Published private(set) var state: State<[Recipe]> = .idle
    
    private var cancellables = Set<AnyCancellable>()
    let service: CoreDataService
    
    init(service: CoreDataService = DIContainer.shared.coreDataService) {
        self.service = service
    }
    
    func fetchRecipes() {
        state = .loading
        service.fetchRecipes()
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
        service.addRecipe(name: name, ingredients: ingredients, image: image?.pngData(), notes: notes)
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
        service.delete(recipe: recipe)
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
    
    func updateRecipe(_ recipe: Recipe, name: String, ingredients: [IngredientData], image: UIImage?, notes: String?) {
        service.update(recipe: recipe, name: name, ingredients: ingredients, image: image?.pngData(), notes: notes)
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
