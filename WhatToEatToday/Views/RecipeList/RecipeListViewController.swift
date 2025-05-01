//
//  RecipeListViewController.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-04-22.
//

import UIKit
import CryptoKit
import Combine

class RecipeListViewController: BaseViewController {
    
    let imageCache = NSCache<NSString, UIImage>()
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let emptyStateView = EmptyView(with: "No Recipes Found! \n Please use the + button to add one")
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let recipeCellName = "RecipeCell"
    
    let viewModel: RecipeListViewModel
    private var recipes = [Recipe]()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RecipeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        setupViewModelBinding()
        toggleNavigationLeftBarItem()
        viewModel.fetchRecipes()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecipeCell.self, forCellReuseIdentifier: recipeCellName)
        tableView.backgroundView = loadingIndicator
        tableView.pin(to: view)
    }
    
    private func setupViewModelBinding() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: State<[Recipe]>) {
        switch state {
        case .idle:
            break
        case .loading:
            loadingIndicator.startAnimating()
        case .success(let recipes):
            loadingIndicator.stopAnimating()
            self.recipes = recipes
            if recipes.isEmpty {
                self.tableView.backgroundView = emptyStateView
            } else {
                self.tableView.backgroundView = nil
                self.tableView.reloadData()
            }
            toggleNavigationLeftBarItem()
        case .failure(let error):
            print("Error fetching from data: \(error.localizedDescription)")
        }
    }

    private func toggleNavigationLeftBarItem() {
        navigationItem.leftBarButtonItem = recipes.isEmpty ? nil : editButtonItem
    }
    
    private func deleteRecipe(at indexPath: IndexPath) {
        let recipeToDelete = recipes[indexPath.row]
        recipes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        viewModel.deleteRecipe(recipeToDelete)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

// MARK: - UITableViewDelegate
extension RecipeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = RecipeViewModel()
        show(RecipeDetailViewController(recipe: recipes[indexPath.row], viewModel: viewModel), sender: self)
    }
}

// MARK: - UITableViewDataSource
extension RecipeListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteRecipe(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: recipeCellName, for: indexPath) as! RecipeCell
        cell.selectionStyle = .none
        cell.recipeLabel.text = recipes[indexPath.row].name
        if let imageData = recipes[indexPath.row].image {
            let cacheKey = imageData.sha256() as NSString
            if let image = imageCache.object(forKey: cacheKey) {
                cell.imagePreview.image = image
            } else {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let image = UIImage(data: imageData) {
                        self?.imageCache.setObject(image, forKey: cacheKey)
                        DispatchQueue.main.async {
                            cell.imagePreview.image = image
                        }
                    }
                }
            }
        }

        return cell
    }
}

extension Data {
    func sha256() -> String {
        let hash = SHA256.hash(data: self)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
