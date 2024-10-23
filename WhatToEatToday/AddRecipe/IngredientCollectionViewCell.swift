//
//  IngredientCollectionViewCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-08-07.
//

import UIKit

class IngredientCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    static let identifier = "IngredientCollectionViewCell"
    
    let textField: UITextField = {
        let textField = PaddedTextField(padding: .init(top: 0, left: 10, bottom: 0, right: 0))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 14, weight: .bold)
        return textField
    }()
    
    var onTextChange: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        setupBorder()
        contentView.addSubview(textField)

        textField.pin(to: contentView)
        textField.delegate = self
    }
    
    func setupBorder() {
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 0.6
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.masksToBounds = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("HT ---- Text Field did change")
        guard let text = textField.text, !text.isEmpty, text != textField.placeholder else {
            return
        }
        onTextChange?(text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func configure(with text: String) {
        textField.text = text
    }
}
