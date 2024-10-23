import UIKit
import Combine

// TODO: View when there is no items
class SlotMachineViewController: UIViewController {

    private var items = [Recipe]()
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
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "No Recipes Found! \n Please use the + button to add one"
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var slotView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var spinButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Spin", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(spinButtonTapped), for: .touchUpInside)
        return button
    }()
   
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
            loadingIndicator.startAnimating()
            break
        case .success(let recipes):
            loadingIndicator.stopAnimating()
            self.items = recipes
            if items.isEmpty {
                emptyLabel.isHidden = false
            } else {
                emptyLabel.isHidden = true
                addSlotMachineView()
            }
        case .failure(let error):
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = false
            removeSlotMachineView()
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
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func addSlotMachineView() {
        
        // To prevent the large title from collapsing
        view.addSubview(UIView())
        
        view.addSubview(containerView)
        containerView.addSubview(slotView)
        view.addSubview(spinButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: itemHeight),
            
            slotView.topAnchor.constraint(equalTo: containerView.topAnchor),
            slotView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            slotView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            slotView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            spinButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            spinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinButton.widthAnchor.constraint(equalToConstant: 100),
            spinButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupSlotItems()
    }

    private func setupSlotItems() {
        let extendedItems = Array(repeating: items, count: 100).flatMap { $0 }
        print("HT ----- extend items count: \(extendedItems.count)")
        var previousLabel: UILabel?
        for (_, item) in extendedItems.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = item.name
            label.font = .systemFont(ofSize: 60)
            label.textAlignment = .center
            slotView.addSubview(label)
//            label.frame = CGRect(x: 0, y: CGFloat(index) * itemHeight, width: 300, height: itemHeight)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: slotView.centerXAnchor),
                label.heightAnchor.constraint(equalToConstant: itemHeight),
                label.topAnchor.constraint(equalTo: previousLabel?.bottomAnchor ?? slotView.topAnchor)
            ])
            
            previousLabel = label
        }
        
        if let lastLabel = previousLabel {
            lastLabel.bottomAnchor.constraint(equalTo: slotView.bottomAnchor).isActive = true
        }
        
//        slotView.contentSize = CGSize(width: 300, height: CGFloat(extendedItems.count) * itemHeight)
        print("HT ----- slotView content size: \(slotView.contentSize)")
        // Set initial position to the middle set of items
        slotView.contentOffset.y = CGFloat(items.count) * itemHeight
    }
    
    @objc private func spinButtonTapped() {
        guard !isSpinning else { return }
        startSpin()
    }
    
    private func startSpin() {
        isSpinning = true
        spinButton.isEnabled = false
        
        let totalDuration: TimeInterval = 3.0
        let initialSpinDuration: TimeInterval = 2.0
        let slowDownDuration: TimeInterval = 0.5
        let finalAdjustmentDuration: TimeInterval = 0.5
        
//        let spinRotations = 3
        let spinDistance = CGFloat(items.count * 20) * itemHeight // Spin through 20 sets of items
        let slowDownDistance = CGFloat(items.count * 5) * itemHeight
        
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0, options: [.calculationModeCubic], animations: {
            // Fast spin
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: initialSpinDuration / totalDuration) {
                self.slotView.contentOffset.y += spinDistance
            }
            
            // Slow down
            UIView.addKeyframe(withRelativeStartTime: initialSpinDuration / totalDuration, relativeDuration: slowDownDuration / totalDuration) {
                self.slotView.contentOffset.y += slowDownDistance
            }
            
            // Final adjustment
            UIView.addKeyframe(withRelativeStartTime: (initialSpinDuration + slowDownDuration) / totalDuration, relativeDuration: finalAdjustmentDuration / totalDuration) {
                let randomIndex = Int.random(in: 0..<self.items.count)
                let targetY = (CGFloat(self.items.count + randomIndex) * self.itemHeight)
                self.slotView.contentOffset.y = targetY
            }
        }) { _ in
            self.stopSpin()
        }
    }
    
    private func stopSpin() {
        isSpinning = false
        spinButton.isEnabled = true
        
        currentIndex = Int(slotView.contentOffset.y / itemHeight) % items.count
        
        // Ensure the slot view is perfectly aligned
        UIView.animate(withDuration: 0.1) {
            self.slotView.contentOffset.y = CGFloat(self.currentIndex + self.items.count) * self.itemHeight
        } completion: { _ in
            self.showResult()
        }
    }
    
    private func showResult() {
        let resultVC = ResultViewController(selectedItem: items[currentIndex].name ?? "")
        present(resultVC, animated: true, completion: nil)
    }
    
    private func removeSlotMachineView() {
        containerView.removeFromSuperview()
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
