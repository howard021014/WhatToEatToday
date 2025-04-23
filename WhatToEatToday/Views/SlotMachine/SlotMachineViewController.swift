import UIKit
import Combine

class SlotMachineViewController: BaseViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        addLoadingIndicator()
        addEmptyLabel()
        setupViewModelBinding()
        viewModel.fetchRecipes()
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
                removeSlotMachineView()
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
        slotView?.delegate = self
        
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

extension SlotMachineViewController: SlotMachineViewDelegate {
    func showResult(_ name: String) {
        let alert = UIAlertController(title: nil, message: "\(name) is your meal today!!", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}
