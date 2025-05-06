//
//  BaseViewController.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-12-08.
//

import UIKit

class BaseViewController: UIViewController {
    
    var onAddButtonTapped: (() -> Void)?
    
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
        onAddButtonTapped?()
    }
}
