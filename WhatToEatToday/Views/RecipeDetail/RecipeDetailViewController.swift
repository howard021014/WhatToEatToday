//
//  AddRecipeTableViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import UIKit
import PhotosUI

class RecipeDetailViewController: UITableViewController, TextFieldCellDelegate, PHPickerViewControllerDelegate {

    var ingredientData = [IngredientData]()

    let recipe: Recipe
    
    init(_ recipe: Recipe) {
        self.recipe = recipe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RecipeImageCell.self, forCellReuseIdentifier: RecipeImageCell.identifier)
        tableView.register(RecipeNameCell.self, forCellReuseIdentifier: RecipeNameCell.identifier)
        tableView.register(RecipeNotesCell.self, forCellReuseIdentifier: RecipeNotesCell.identifier)
        tableView.register(IngredientCell.self, forCellReuseIdentifier: IngredientCell.identifier)
        tableView.register(IngredientsHeaderView.self, forHeaderFooterViewReuseIdentifier: IngredientsHeaderView.identifier)
        
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        navigationItem.largeTitleDisplayMode = .never
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveRecipe))
        if let ingredients = recipe.ingredients?.array as? [Ingredient] {
            for ingredient in ingredients {
                ingredientData.append(IngredientData(name: ingredient.name ?? "", unit: ingredient.unit ?? ""))
            }
        }
    }

//    @objc
//    func saveRecipe() {
//        tableView.endEditing(true)
//        
//        viewModel.addRecipe(name: recipeName ?? "", ingredients: ingredientData, image: recipeImage, notes: recipeNotes)
//        
//        dismiss(animated: true)
//    }
    
    func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 3:
            return 1
        case 2:
            return ingredientData.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecipeImageCell.identifier, for: indexPath) as? RecipeImageCell {
                if let imageData = recipe.image {
                    cell.configure(with: UIImage(data: imageData))
                }
//                cell.onUploadButtonTapped = { [weak self] in
//                    self?.showImagePicker()
//                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecipeNameCell.identifier, for: indexPath) as? RecipeNameCell {
                cell.configure(with: recipe.name)
                cell.delegate = self
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.identifier, for: indexPath) as? IngredientCell {
                cell.configure(with: ingredientData[indexPath.row])
//                cell.onIngredientDataUpdate = { [weak self] updatedData in
//                    self?.ingredientData[indexPath.row] = updatedData
//                }
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: RecipeNotesCell.identifier, for: indexPath) as? RecipeNotesCell {
                cell.configure(with: recipe.notes)
                cell.delegate = self
                return cell
            }
        default:
            return UITableViewCell()
        }

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Recipe Name"
        case 2:
            return "Ingredients"
        case 3:
            return "Extra Notes"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 300
        case 2:
            return 44
        case 3:
            return 300
        default:
            return tableView.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            // Get the default header view
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") ?? UITableViewHeaderFooterView(reuseIdentifier: "header")

            // Add a button to the header view
            let addButton = UIButton(type: .system)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.setImage(UIImage(systemName: "plus")!, for: .normal)
            addButton.tag = section
            addButton.addTarget(self, action: #selector(addNewIngredientRow(_:)), for: .touchUpInside)

            // Add the button to the header view
            headerView.contentView.addSubview(addButton)
            NSLayoutConstraint.activate([
                addButton.trailingAnchor.constraint(equalTo: headerView.contentView.trailingAnchor, constant: -10),
                addButton.centerYAnchor.constraint(equalTo: headerView.contentView.centerYAnchor),
                addButton.heightAnchor.constraint(equalToConstant: 18.0),
                addButton.widthAnchor.constraint(equalToConstant: 18.0)
            ])

            return headerView
        }
        return nil
    }
    
    @objc
    private func addNewIngredientRow(_ sender: UIButton) {
        let section = sender.tag
        ingredientData.append(IngredientData())
        tableView.insertRows(at: [IndexPath(row: ingredientData.count - 1, section: section)], with: .automatic)
    }
    
    // MARK: - TextFieldDelegate
    func textDidChange(for view: TextFieldTag, text: String?) {
//        switch view {
//        case .name:
//            recipeName = text
//        case .notes:
//            recipeNotes = text
//        }
    }

    // MARK: - PHPPickerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        
//        guard let result = results.first else { return }
//        
//        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
//            if let image = object as? UIImage {
//                DispatchQueue.main.async {
//                    self?.recipeImage = image
//                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//                }
//            }
//        }
    }
}
