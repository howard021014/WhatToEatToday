//
//  CoreDataServiceProtocol.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-10-30.
//

import Combine
import Foundation
import CoreData

protocol CoreDataService {
    func fetchRecipes() -> Future<[Recipe], Error>
    func addRecipe(name: String, ingredients: [IngredientData], image: Data?, notes: String?) -> Future<Void, Error>
    func delete(recipe: Recipe) -> Future<Void, Error>
}


class CoreDataServiceImpl: CoreDataService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchRecipes() -> Future<[Recipe], any Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<Recipe>(entityName: "Recipe")

            let asyncFetchResult = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { fetchResult in
                guard let result = fetchResult.finalResult else {
                    promise(.failure(
                        NSError(
                            domain: "CoreDataService",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "No recipes found"])
                        )
                    )
                    return
                }
                
                promise(.success(result))
            }
            
            do {
                try context.execute(asyncFetchResult)
            } catch let error {
                promise(.failure(error))
            }
        }
    }
    
    func addRecipe(name: String, ingredients: [IngredientData], image: Data?, notes: String?) -> Future<Void, any Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            let recipe = Recipe(context: self.context)
            recipe.name = name
            recipe.image = image
            recipe.notes = notes
            
            for ingredientData in ingredients {
                let ingredient = Ingredient(context: self.context)
                ingredient.name = ingredientData.name
                ingredient.unit = ingredientData.unit
                recipe.addToIngredients(ingredient)
            }
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.success(()))
            }
        }
    }
    
    func delete(recipe: Recipe) -> Future<Void, any Error> {
        Future { [weak self] promise in
            guard let self = self else { return }
            
            self.context.delete(recipe)
            if self.context.hasChanges {
                do {
                    try self.context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.success(()))
            }
        }
    }
}
