//
//  AppCoordinator.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2025-05-05.
//

import Foundation
import UIKit

final class AppCoordinator {
    let store: RecipeStore
    let window: UIWindow
    
    private var tabBar: UITabBarController!
    private var listNav: UINavigationController!
    private var slotNav: UINavigationController!
    
    init(window: UIWindow) {
        self.window = window
        let coreDataService = CoreDataServiceImpl(context: CoreDataStack().container.viewContext)
        self.store = RecipeStore(service: coreDataService)
    }
    
    func start() {
        // Build Slot Machine VC
        let slotVM = SlotMachineViewModel(store: store)
        let slotVC = SlotMachineViewController(viewModel: slotVM)
        slotVC.onAddButtonTapped = { [weak self] in
            self?.showAddRecipeForm()
        }

        slotNav = UINavigationController(rootViewController: slotVC)
        slotNav.tabBarItem = .init(title: "Pick",
                                   image: UIImage(systemName: "menucard"),
                                   tag: 0)

        // Build Recipe List VC
        let listVM = RecipeListViewModel(store: store)
        let listVC = RecipeListViewController(viewModel: listVM)
        listVC.onAddButtonTapped = { [weak self] in
            self?.showAddRecipeForm()
        }
        listVC.onSelectRecipe = { [weak self] recipe in
            self?.showDetailRecipeForm(recipe)
        }
        
        listNav = UINavigationController(rootViewController: listVC)
        listNav.tabBarItem = .init(title: "List",
                                   image: UIImage(systemName: "list.bullet"),
                                   tag: 1)
        // Assemble the Tab bar
        tabBar = UITabBarController()
        tabBar.view.backgroundColor = .white
        tabBar.viewControllers = [slotNav, listNav]

        window.rootViewController = tabBar
        window.makeKeyAndVisible()
    }
    
    private func showAddRecipeForm() {
        let formVM = RecipeFormViewModel(mode: .create, store: store)
        let addVC = RecipeFormViewController(viewModel: formVM)
        let navVC = UINavigationController(rootViewController: addVC)
        tabBar.present(navVC, animated: true)
    }
    
    private func showDetailRecipeForm(_ recipe: Recipe) {
        let formVM = RecipeFormViewModel(mode: .edit(existing: recipe), store: store)
        let detailVC = RecipeFormViewController(viewModel: formVM)
        listNav.pushViewController(detailVC, animated: true)
    }
}
