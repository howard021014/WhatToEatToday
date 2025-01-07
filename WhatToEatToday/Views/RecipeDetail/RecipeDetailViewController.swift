//
//  AddRecipeTableViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import UIKit
import PhotosUI

class RecipeDetailViewController: RecipeBaseTableViewController {
    
    private var recipe: Recipe
    
    init(recipe: Recipe, viewModel: RecipeViewModel) {
        self.recipe = recipe
        super.init(viewModel: viewModel, editable: false)
        
        self.recipeName = recipe.name
        self.recipeImage = UIImage(data: recipe.image ?? Data())
        self.recipeNotes = recipe.notes
        if let ingredients = recipe.ingredients?.array as? [Ingredient] {
            for ingredient in ingredients {
                ingredientData.append(IngredientData(name: ingredient.name ?? "", unit: ingredient.unit ?? ""))
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe Details"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(toggleEdit)
        )
    }
    
    @objc private func toggleEdit() {
        setEditing(!isEditing)
    }
        
    // TODO: - This should be an update
    @objc private func saveRecipe() {
        viewModel.addRecipe(
            name: recipeName ?? "",
            ingredients: ingredientData,
            image: recipeImage,
            notes: recipeNotes
        )
        
        setEditing(false)
    }
    
    func setEditing(_ editing: Bool) {
        // Update navigation bar buttons
        if editing {
            // In edit mode: Show Save and Cancel buttons
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(saveRecipe)
            )
//            navigationItem.leftBarButtonItem = UIBarButtonItem(
//                title: "Cancel",
//                style: .plain,
//                target: self,
//                action: #selector(cancelEdit)
//            )
        } else {
            // In view mode: Show Edit button
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(toggleEdit)
            )
            navigationItem.leftBarButtonItem = nil
        }
        
        // Update all visible cells
        updateCellsEditingState(editing)
    }
    
    private func updateCellsEditingState(_ editing: Bool) {
        // Go through all visible cells and update their editing state
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if let cell = tableView.cellForRow(at: indexPath) as? EditableCell {
                    cell.setEditable(editing)
                }
            }
        }
    }
}
