//
//  RecipeBaseTableViewController.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-12-17.
//

import UIKit
import PhotosUI
import Combine

struct IngredientData {
    var name = ""
    var unit = ""
}

class RecipeFormViewController: UITableViewController {

    let viewModel: RecipeFormViewModel
    var ingredientData = [IngredientData]()
    var recipeName: String?
    var recipeNotes: String?
    var recipeImage: UIImage?
    
    private var cancellables = Set<AnyCancellable>()
    
    enum TableSection: Int {
        case image, name, ingredients, notes
    }
    
    init(viewModel: RecipeFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.mode == .create ? "Create your Recipe" : "Recipe Details"
        setupNavBar()
        setupTableView()
        setupViewModelBindings()
        setupTapRecognizer()
        registerCells()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.allowsSelection = false
    }
    
    private func setupTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(finishEditing))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: viewModel.isEditable ? "Save" : "Edit",
            style: .plain,
            target: self,
            action: #selector(saveOrUpdate)
        )
        
        if viewModel.isEditable && viewModel.mode != .create {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancel)
            )
        }
    }
    
    private func updateNavBarItems(for editable: Bool) {
        navigationItem.rightBarButtonItem?.title = editable ? "Save" : "Edit"
        
        if editable && viewModel.mode != .create {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancel)
            )
        } else {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func setupViewModelBindings() {
        viewModel.$isEditable
            .receive(on: RunLoop.main)
            .sink { [weak self] editable in
                self?.tableView.reloadData()
                self?.updateNavBarItems(for: editable)
            }
            .store(in: &cancellables)
        
        viewModel.$isValid
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid
            }
            .store(in: &cancellables)
    }
    
    private func registerCells() {
        tableView.register(RecipeImageCell.self, forCellReuseIdentifier: RecipeImageCell.identifier)
        tableView.register(RecipeNameCell.self, forCellReuseIdentifier: RecipeNameCell.identifier)
        tableView.register(RecipeNotesCell.self, forCellReuseIdentifier: RecipeNotesCell.identifier)
        tableView.register(IngredientCell.self, forCellReuseIdentifier: IngredientCell.identifier)
    }
    
    func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc
    private func finishEditing() {
        view.endEditing(true)
    }
    
    @objc
    private func saveOrUpdate() {
        if viewModel.isEditable {
            finishEditing()
            viewModel.saveOrUpdate()
            dismiss(animated: true)
        }
        viewModel.toggleEditing()
    }
    
    @objc
    private func cancel() {
        finishEditing()
        viewModel.cancelEdit()
        tableView.reloadData()
        dismiss(animated: true)
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection(rawValue: section) {
        case .image, .name, .notes:
            return 1
        case .ingredients:
            return viewModel.draft.ingredients.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableSection(rawValue: indexPath.section) {
        case .image:
            return configureImageCell(tableView, at: indexPath)
        case .name:
            return configureNameCell(tableView, at: indexPath)
        case .ingredients:
            return configureIngredientCell(tableView, at: indexPath)
        case .notes:
            return configureNotesCell(tableView, at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func configureImageCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeImageCell.identifier, for: indexPath) as? RecipeImageCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: viewModel.draft.recipeImage)
        cell.setEditable(viewModel.isEditable)
        
        cell.onUploadButtonTapped = { [weak self] in
            self?.showImagePicker()
        }
        return cell
    }
    
    private func configureNameCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeNameCell.identifier, for: indexPath) as? RecipeNameCell else {
            return UITableViewCell()
        }

        cell.bind(to: viewModel)
        return cell
    }
    
    private func configureIngredientCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.identifier, for: indexPath) as? IngredientCell else {
            return UITableViewCell()
        }

        cell.bind(to: viewModel, at: indexPath)
        return cell
    }
    
    private func configureNotesCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeNotesCell.identifier, for: indexPath) as? RecipeNotesCell else {
            return UITableViewCell()
        }
        
        cell.bind(to: viewModel)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch TableSection(rawValue: section) {
        case .name:
            return "Recipe Name"
        case .ingredients:
            return "Ingredients"
        case .notes:
            return "Extra Notes"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if case .image = TableSection(rawValue: section) {
            return 0
        }
        
        return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TableSection(rawValue: indexPath.section) {
        case .image:
            return 300
        case .ingredients:
            return 44
        case .notes:
            return 300
        default:
            return tableView.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if case .ingredients = TableSection(rawValue: section) {
            // Get the default header view
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") ?? UITableViewHeaderFooterView(reuseIdentifier: "header")
            
            // Add a button to the header view
            let addButton = UIButton(type: .system)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.setImage(UIImage(systemName: "plus")!, for: .normal)
            addButton.tag = section
            addButton.addTarget(self, action: #selector(addNewIngredientRow(_:)), for: .touchUpInside)
            
            addButton.isEnabled = viewModel.isEditable
            addButton.isUserInteractionEnabled = viewModel.isEditable

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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        TableSection(rawValue: indexPath.section) == .ingredients
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates {
                viewModel.draft.ingredients.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    @objc
    private func addNewIngredientRow(_ sender: UIButton) {
        let section = sender.tag
        tableView.performBatchUpdates {
            viewModel.draft.ingredients.append(IngredientData())
            tableView.insertRows(at: [IndexPath(row: viewModel.draft.ingredients.count - 1, section: section)], 
                                 with: .automatic)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension RecipeFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.viewModel.draft.recipeImage = image
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
        }
    }
}
