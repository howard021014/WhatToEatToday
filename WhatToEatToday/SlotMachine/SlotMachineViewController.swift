import UIKit
import Combine

class SlotMachineViewController: UIViewController {
    
    private var recipes = [Recipe]()
    private var currentIndex = 0
    private var isSpinning = false
    private var cancellables = Set<AnyCancellable>()
    
    private let itemHeight: CGFloat = 100
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        return loadingView
    }()
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView(with: "No Recipes Found! \n Please use the + button to add one")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
   
    var slotView: SlotMachineView?
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
        view.backgroundColor = .white
        
        // To prevent the large title from collapsing
        view.addSubview(UIView())
        setupViewModelBinding()
        viewModel.fetchRecipes()
        addLoadingIndicator()
        addEmptyLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipe))
        self.tabBarController?.navigationItem.setRightBarButton(addButton, animated: true)
    }
    
    @objc
    func addRecipe() {
        let vc = AddRecipeTableViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    private func setupViewModelBinding() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: State) {
        switch state {
        case .idle:
            break
        case .loading:
            emptyView.isHidden = true
            removeSlotMachineView()
            loadingIndicator.startAnimating()
            break
        case .success(let recipes):
            loadingIndicator.stopAnimating()
            self.recipes = recipes
            if recipes.isEmpty {
                emptyView.isHidden = false
                slotView?.isHidden = true
            } else {
                emptyView.isHidden = true
                slotView?.isHidden = false
                setupSlotMachineViews()
            }
        case .failure(let error):
            loadingIndicator.stopAnimating()
            emptyView.isHidden = false
            slotView?.isHidden = true
            print("Error fetching from data: \(error.localizedDescription)")
        }
    }
    
    private func addLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func addEmptyLabel() {
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupSlotMachineViews() {
        
        slotView = SlotMachineView(recipes: recipes)
        slotView?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(slotView!)
        NSLayoutConstraint.activate([
            slotView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slotView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slotView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            slotView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func removeSlotMachineView() {
        slotView?.removeFromSuperview()
        slotView = nil
    }
}




class ResultViewController: UIViewController {
    
    private let selectedItem: String
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 100)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("OK", for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(selectedItem: String) {
        self.selectedItem = selectedItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(resultLabel)
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            dismissButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        resultLabel.text = selectedItem
    }
    
    @objc private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
