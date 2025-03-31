//
//  RecipeNameCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

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
    
    weak var delegate: TextFieldCellDelegate?
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let enteredText = textField.text, enteredText != textField.placeholder, !enteredText.isEmpty else {
            return
        }

        delegate?.textDidChange(for: .name, text: enteredText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recipeNameTextField.resignFirstResponder()
        return true
    }
    
    func configure(with text: String?) {
        recipeNameTextField.text = text
    }
    
    func setEditable(_ editable: Bool) {
        recipeNameTextField.isEnabled = editable
        recipeNameTextField.backgroundColor = editable ? .systemBackground : .systemGray6
    }
}
