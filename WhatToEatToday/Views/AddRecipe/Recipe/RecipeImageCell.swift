//
//  ImageViewCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import Combine
import UIKit

class RecipeImageCell: UITableViewCell {
    
    static let identifier = "RecipeImageCell"

    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var cancellables = Set<AnyCancellable>()
    var onUploadButtonTapped: (() -> Void)?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(uploadButton)

        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            recipeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            uploadButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            uploadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadButtonTapped))
        recipeImageView.addGestureRecognizer(tapGesture)
        recipeImageView.isUserInteractionEnabled = true
    }

    func bind(to viewModel: RecipeFormViewModel) {

        viewModel.draft.$recipeImage
            .receive(on: RunLoop.main)
            .sink { [weak self] image in
                self?.configure(with: image)
            }
            .store(in: &cancellables)
        
        viewModel.$isEditable
            .receive(on: RunLoop.main)
            .sink { [weak self] editable in
                self?.recipeImageView.isUserInteractionEnabled = editable
            }
            .store(in: &cancellables)
    }

    private func configure(with image: UIImage?) {
        if let image {
            recipeImageView.image = image
            uploadButton.isHidden = true
            recipeImageView.isHidden = false
        } else {
            uploadButton.isHidden = false
            recipeImageView.isHidden = true
        }
    }

    @objc
    private func uploadButtonTapped() {
        onUploadButtonTapped?()
    }
    
}
