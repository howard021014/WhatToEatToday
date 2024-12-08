//
//  BaseViewController.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-12-08.
//

import UIKit

class BaseViewController: UIViewController {

    let viewModel: RecipeViewModel
    
    init(viewModel: RecipeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "What to eat today?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipe))
    }

    @objc
    func addRecipe() {
        let vc = AddRecipeTableViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
