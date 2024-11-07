//
//  ViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-04-22.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let viewModel: RecipeViewModel
    
    init(viewModel: RecipeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var gameVC: UIViewController = {
//        let vc = GameViewController()
        let vc = SlotMachineViewController(viewModel: viewModel)
        let tabBarItem = UITabBarItem(title: "Pick", image: UIImage(systemName: "menucard"), tag: 0)
        vc.tabBarItem = tabBarItem
        return vc
    }()

    lazy var listVC: UIViewController = {
        let vc = RecipeListViewController(viewModel: viewModel)
        let tabBarItem = UITabBarItem(title: "List", image: UIImage(systemName: "list.bullet"), tag: 1)
        vc.tabBarItem = tabBarItem
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        viewControllers = [gameVC, listVC]

//        viewModel.addSampleRecipes()
        
        self.title = "What to eat today?"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

