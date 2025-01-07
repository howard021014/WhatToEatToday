//
//  AddRecipeTableViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import UIKit

class AddRecipeTableViewController: RecipeBaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create your Recipe"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveRecipe))
    }
    
    @objc
    func saveRecipe() {
        tableView.endEditing(true)
        
        viewModel.addRecipe(name: recipeName ?? "", ingredients: ingredientData, image: recipeImage, notes: recipeNotes)
        
        dismiss(animated: true)
    }
}
