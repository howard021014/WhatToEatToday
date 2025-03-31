//
//  AddRecipeTableViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import Combine
import UIKit

class RecipeDetailViewController: RecipeBaseTableViewController {
    
    private var recipe: Recipe
    private var cancellables = Set<AnyCancellable>()
    
    init(recipe: Recipe, viewModel: RecipeViewModel) {
        self.recipe = recipe
        super.init(viewModel: viewModel, isEditable: false)
        setOriginalValues()
        setupBindings()
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
    
    private func setupBindings() {
        $isEditable
            .receive(on: RunLoop.main)
            .sink { [weak self] editable in
                self?.updateUIForEditingState(editable)
                self?.updateAddIngredientButtonVisibility(editable)
            }
            .store(in: &cancellables)
    }
    
    @objc private func toggleEdit() {
        isEditable = !isEditing
    }

    @objc private func updateRecipe() {
        viewModel.updateRecipe(
            recipe,
            name: recipeName ?? "",
            ingredients: ingredientData,
            image: recipeImage,
            notes: recipeNotes
        )
        
        isEditable = false
    }
    
    private func updateUIForEditingState(_ editing: Bool) {
        // Update navigation bar buttons
        if editing {
            // In edit mode: Show Save and Cancel buttons
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save",
                style: .done,
                target: self,
                action: #selector(updateRecipe)
            )
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancelEdit)
            )

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
    }
    
    @objc
    private func cancelEdit() {
        ingredientData.removeAll()
        setOriginalValues()
        isEditable = false
        tableView.reloadData()
    }
    
    private func setOriginalValues() {
        self.recipeName = recipe.name
        self.recipeImage = UIImage(data: recipe.image ?? Data())
        self.recipeNotes = recipe.notes
        if let ingredients = recipe.ingredients?.array as? [Ingredient] {
            for ingredient in ingredients {
                ingredientData.append(IngredientData(name: ingredient.name ?? "", unit: ingredient.unit ?? ""))
            }
        }
    }
}
