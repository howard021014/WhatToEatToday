//
//  ViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-04-22.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    lazy var gameVC: UIViewController = {
        let slotMachineViewModel = SlotMachineViewModel(store: store)
        let vc = SlotMachineViewController(viewModel: slotMachineViewModel)
        let navVc = UINavigationController(rootViewController: vc)
        let tabBarItem = UITabBarItem(title: "Pick", image: UIImage(systemName: "menucard"), tag: 0)
        vc.tabBarItem = tabBarItem
        return navVc
    }()

    lazy var listVC: UIViewController = {
        let listViewModel = RecipeListViewModel(store: store)
        let vc = RecipeListViewController(viewModel: listViewModel)
        let navVc = UINavigationController(rootViewController: vc)
        let tabBarItem = UITabBarItem(title: "List", image: UIImage(systemName: "list.bullet"), tag: 1)
        vc.tabBarItem = tabBarItem
        return navVc
    }()

    let store: RecipeStore
    
    init(store: RecipeStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        viewControllers = [gameVC, listVC]
        
        self.title = "What to eat today?"
    }
}

