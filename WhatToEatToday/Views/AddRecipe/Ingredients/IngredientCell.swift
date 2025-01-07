//
//  IngredientCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-04-25.
//

import UIKit

protocol IngredientDataDelegate: AnyObject {
    func saveIngredient(name: String, unit: String)
}

class IngredientCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EditableCell {

    static let identifier = "IngredientCell"
    var ingredientData = IngredientData()
    var viewing: Bool = false
    var onIngredientDataUpdate: ((IngredientData) -> Void)?

    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(IngredientCollectionViewCell.self, forCellWithReuseIdentifier: IngredientCollectionViewCell.identifier)
        
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCollectionViewCell.identifier, for: indexPath) as? IngredientCollectionViewCell {
            if viewing {
                if indexPath.item == 0 {
                    cell.setEditable(!viewing)
                    cell.configure(with: ingredientData.name)
                } else {
                    cell.setEditable(!viewing)
                    cell.configure(with: ingredientData.unit)
                }
            } else {
                if indexPath.item == 0 {
                    cell.textField.placeholder = "Item Name"
                } else {
                    cell.textField.placeholder = "Unit"
                }
                cell.onTextChange = { [weak self] text in
                    print("HT ---- Text changed: \(text) at \(indexPath.item) at row: \(indexPath.row)")
                    if indexPath.item == 0 {
                        self?.ingredientData.name = text
                    } else {
                        self?.ingredientData.unit = text
                    }
                    self?.onIngredientDataUpdate?(self?.ingredientData ?? IngredientData())
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 10
        if indexPath.item == 0 {
            return CGSize(width: width * 2 / 3, height: collectionView.bounds.height)
        } else {
            return CGSize(width: width / 3, height: collectionView.bounds.height)
        }
    }
    
    func configure(with ingredientData: IngredientData) {
        viewing = true
        self.ingredientData = ingredientData
    }
    
    func setEditable(_ editable: Bool) {
        viewing = !editable
    }
}
