//
//  RecipeNameCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import Combine
import UIKit

class RecipeNameCell: UITableViewCell, UITextFieldDelegate, EditableCell {

    static let identifier = "RecipeNameCell"
    
    let recipeNameTextField: PaddedTextField = {
        let textField = PaddedTextField(padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 20.0, weight: .bold)
        textField.placeholder = "Enter a name for your recipe"
        return textField
    }()
    
    private lazy var textPublisher: AnyPublisher<String, Never> = {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: recipeNameTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setUpBorder()
        recipeNameTextField.delegate = self
        contentView.addSubview(recipeNameTextField)
        
        NSLayoutConstraint.activate([
            recipeNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            recipeNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            recipeNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            recipeNameTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setUpBorder() {
        recipeNameTextField.layer.cornerRadius = 8
        recipeNameTextField.layer.borderWidth = 0.6
        recipeNameTextField.layer.borderColor = UIColor.black.cgColor
        recipeNameTextField.layer.masksToBounds = true
    }
    
    func bind(to viewModel: RecipeFormViewModel) {
        // Emits text and assign to view model property (UI -> VM)
        textPublisher
            .receive(on: RunLoop.main)
            .assign(to: &viewModel.draft.$recipeName)
        
        // Toggles the editable state based on view model (VM -> UI)
        viewModel.$isEditable
            .receive(on: RunLoop.main)
            .sink { [weak self] editable in
                self?.setEditable(editable)
            }
            .store(in: &cancellables)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recipeNameTextField.resignFirstResponder()
        return true
    }
    
    func setEditable(_ editable: Bool) {
        recipeNameTextField.isEnabled = editable
        recipeNameTextField.backgroundColor = editable ? .systemBackground : .systemGray6
    }
}
