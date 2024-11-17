//
//  IngredientsHeaderView.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import UIKit

class IngredientsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "IngredientsHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ingredients"
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Ingredient", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
}
