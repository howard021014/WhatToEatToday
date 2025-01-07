//
//  RecipeBaseTableViewController.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-12-17.
//

import UIKit
import PhotosUI

struct IngredientData {
    var name = ""
    var unit = ""
}

class RecipeBaseTableViewController: UITableViewController {

    let viewModel: RecipeViewModel
    let editable: Bool
    
    var ingredientData = [IngredientData]()
    var recipeName: String?
    var recipeNotes: String?
    var recipeImage: UIImage?
    
    init(viewModel: RecipeViewModel, editable: Bool = true) {
        self.viewModel = viewModel
        self.editable = editable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCells()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
    }
    
    private func registerCells() {
        tableView.register(RecipeImageCell.self, forCellReuseIdentifier: RecipeImageCell.identifier)
        tableView.register(RecipeNameCell.self, forCellReuseIdentifier: RecipeNameCell.identifier)
        tableView.register(RecipeNotesCell.self, forCellReuseIdentifier: RecipeNotesCell.identifier)
        tableView.register(IngredientCell.self, forCellReuseIdentifier: IngredientCell.identifier)
        tableView.register(IngredientsHeaderView.self, forHeaderFooterViewReuseIdentifier: IngredientsHeaderView.identifier)
    }
    
    func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - UITableViewDataSource
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
        print("HT ----- Table view populating the cell in \(#function)")
        switch indexPath.section {
        case 0:
            return configureImageCell(tableView, at: indexPath)
        case 1:
            return configureNameCell(tableView, at: indexPath)
        case 2:
            return configureIngredientCell(tableView, at: indexPath)
        case 3:
            return configureNotesCell(tableView, at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func configureImageCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeImageCell.identifier, for: indexPath) as? RecipeImageCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: recipeImage)
        cell.setEditable(editable)
        cell.onUploadButtonTapped = { [weak self] in
            self?.showImagePicker()
        }
        return cell
    }
    
    private func configureNameCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeNameCell.identifier, for: indexPath) as? RecipeNameCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: recipeName)
        cell.setEditable(editable)
        cell.delegate = self
        return cell
    }
    
    private func configureIngredientCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.identifier, for: indexPath) as? IngredientCell else {
            return UITableViewCell()
        }

        cell.configure(with: ingredientData[indexPath.row])
        cell.setEditable(editable)
        cell.onIngredientDataUpdate = { [weak self] updatedData in
            self?.ingredientData[indexPath.row] = updatedData
        }
        return cell
    }
    
    private func configureNotesCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeNotesCell.identifier, for: indexPath) as? RecipeNotesCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: recipeNotes)
        cell.setEditable(editable)
        cell.delegate = self
        return cell
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
            if editable {
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
            }

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
}

extension RecipeBaseTableViewController: TextFieldCellDelegate {
    func textDidChange(for view: TextFieldTag, text: String?) {
        switch view {
        case .name:
            recipeName = text
        case .notes:
            recipeNotes = text
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension RecipeBaseTableViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.recipeImage = image
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
        }
    }
}
