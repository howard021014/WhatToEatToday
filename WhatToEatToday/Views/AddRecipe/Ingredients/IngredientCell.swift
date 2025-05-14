//
//  IngredientCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-04-25.
//

import Combine
import UIKit

class IngredientCell: UITableViewCell {
    
    static let identifier = "IngredientCell"

    let nameTextField: PaddedTextField = {
        let textField = PaddedTextField(padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 14, weight: .bold)
        textField.placeholder = "Ingredient Name"
        return textField
    }()
    
    let unitTextField: PaddedTextField = {
        let textField = PaddedTextField(padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 14, weight: .bold)
        textField.placeholder = "Unit"
        return textField
    }()
    
    let paddingHorizontal: CGFloat = 10
    let paddingVertical: CGFloat = 5
    let interItemSpacing: CGFloat = 10
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    private func setupUI() {
        contentView.addSubview(nameTextField)
        contentView.addSubview(unitTextField)

        NSLayoutConstraint.activate([
            // Ingredient name text field constraints
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: paddingVertical),
            nameTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -paddingVertical),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: paddingHorizontal),
            nameTextField.trailingAnchor.constraint(equalTo: unitTextField.leadingAnchor, constant: -interItemSpacing),
            
            // Ingredient unit text field constraints
            unitTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: paddingVertical),
            unitTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -paddingVertical),
            unitTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -paddingHorizontal),
            
            nameTextField.widthAnchor.constraint(equalTo: unitTextField.widthAnchor, multiplier: 2.0),
        ])
    }
    
    func bind(to viewModel: RecipeFormViewModel, at indexPath: IndexPath) {
        // Combine both textfield publisher and map to actual data object
        Publishers.CombineLatest(nameTextField.textDidChangePublisher, unitTextField.textDidChangePublisher)
            .map { name, unit in
                IngredientData(name: name, unit: unit)
            }
            .receive(on: RunLoop.main)
            .sink { [weak viewModel] data in
                viewModel?.draft.ingredients[indexPath.row] = data
            }
            .store(in: &cancellables)
        
        // Update textfield with new text
        viewModel.draft.$ingredients
            .receive(on: RunLoop.main)
            .sink { [weak self] ingredientData in
                // Make sure that the data does not go index out of bounds because the original copy will be 1 less than the newly added row
                // this happens when user adds a row and then decides to cancel
                if indexPath.row < ingredientData.count {
                    self?.nameTextField.text = ingredientData[indexPath.row].name
                    self?.unitTextField.text = ingredientData[indexPath.row].unit
                }
            }
            .store(in: &cancellables)

        viewModel.$isEditable
            .receive(on: RunLoop.main)
            .sink { [weak self] isEditable in
                self?.nameTextField.setEditable(isEditable)
                self?.unitTextField.setEditable(isEditable)
            }
            .store(in: &cancellables)
    }
}
