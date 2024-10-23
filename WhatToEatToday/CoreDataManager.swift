//
//  CoreDataManager.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-06-23.
//

import Foundation
import CoreData

import UIKit

typealias RecipeCompletion = ((Result<[Recipe], Error>) -> Void)

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let containerName = "Recipes"
    let entityName = "Recipe"

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() { }

    func saveContext() {
//        let context = persistentContainer.newBackgroundContext()
//        context.automaticallyMergesChangesFromParent = true
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveRecipe(name: String, ingredients: [IngredientData], image: Data?, notes: String?) {
        let recipe = Recipe(context: viewContext)
        recipe.name = name
        recipe.image = image
        recipe.notes = notes
        
        for ingredientData in ingredients {
            let ingredient = Ingredient(context: viewContext)
            ingredient.name = ingredientData.name
            ingredient.unit = ingredientData.unit
            recipe.addToIngredients(ingredient)
        }
        
        saveContext()
    }
    
    func fetchRecipes(completion: @escaping RecipeCompletion) {
        let fetchRequest = NSFetchRequest<Recipe>(entityName: entityName)
        
        let asyncFetchResult = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { fetchResult in
            guard let result = fetchResult.finalResult else {
                completion(.failure(NSError(domain: "CoreDataManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No recipes found"])))
                return
            }
            
            completion(.success(result))
        }
        
        do {
            try viewContext.execute(asyncFetchResult)
        } catch let error {
            print("Error while fetching the recipes: \(error)")
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        viewContext.delete(recipe)
        saveContext()
    }
    
    func generateDummyData() {
        for i in 0..<50 {
            let recipe = Recipe(context: viewContext)
            recipe.name = "\(i) Menu"
            recipe.image = UIImage(named: "placeholder")?.pngData()
            recipe.notes = "\(i) notes"
            
            let ingredient = Ingredient(context: viewContext)
            ingredient.name = "\(i) Ingredient name"
            ingredient.unit = "\(i) Ingredient unit"
            recipe.addToIngredients(ingredient)
        }
        
        saveContext()
    }
}
