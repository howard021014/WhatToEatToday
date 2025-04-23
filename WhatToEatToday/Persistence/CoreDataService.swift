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
    func fetchRecipes() async throws -> [Recipe]
    func addRecipe(
        name: String,
        ingredients: [IngredientData],
        image: Data?,
        notes: String?
    ) async throws
    func delete(recipe: Recipe) async throws
    func update(
        recipe: Recipe,
        name: String,
        ingredients: [IngredientData],
        image: Data?,
        notes: String?) async throws
}


class CoreDataServiceImpl: CoreDataService {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        try await withCheckedThrowingContinuation { continuation in
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            let asyncFetchResult = NSAsynchronousFetchRequest(fetchRequest: request) { fetchResult in
                if let recipes = fetchResult.finalResult {
                    continuation.resume(returning: recipes)
                } else if let error = fetchResult.operationError {
                    continuation.resume(throwing: error)
                }
            }
            
            do {
                try container.viewContext.execute(asyncFetchResult)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func addRecipe(
        name: String,
        ingredients: [IngredientData],
        image: Data?,
        notes: String?
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { ctx in
                let recipe = Recipe(context: ctx)
                recipe.name = name
                recipe.image = image
                recipe.notes = notes
                for ingData in ingredients {
                    let ing = Ingredient(context: ctx)
                    ing.name = ingData.name
                    ing.unit = ingData.unit
                    recipe.addToIngredients(ing)
                }
                do {
                    try ctx.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func delete(recipe: Recipe) async throws {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { ctx in
                // Obtain a “local” copy in this context
                let local = ctx.object(with: recipe.objectID)
                ctx.delete(local)
                do {
                    try ctx.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func update(
        recipe: Recipe,
        name: String,
        ingredients: [IngredientData],
        image: Data?,
        notes: String?
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { ctx in
                let local = ctx.object(with: recipe.objectID) as! Recipe
                // Update fields
                local.name = name
                local.image = image
                local.notes = notes
                // Replace ingredients
                if let existing = local.ingredients?.array as? [Ingredient] {
                    for ing in existing {
                        local.removeFromIngredients(ing)
                        ctx.delete(ing)
                    }
                }
                for ingData in ingredients {
                    let ing = Ingredient(context: ctx)
                    ing.name = ingData.name
                    ing.unit = ingData.unit
                    local.addToIngredients(ing)
                }
                do {
                    try ctx.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
