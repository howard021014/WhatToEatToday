//
//  SlotMachineView.swift
//  WhatToEatToday
//
//  Created by Howard tsai on 2024-11-12.
//

import UIKit

protocol SlotMachineViewDelegate {
    func showResult(_ name: String)
}

class SlotMachineView: UIView {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let itemHeight: CGFloat = 100
    private var isSpinning = false
    private var currentIndex = 0

    let recipes: [Recipe]
    var delegate: SlotMachineViewDelegate?
    
    init(recipes: [Recipe]) {
        self.recipes = recipes
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        containerView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        buttonContainerView.addSubview(spinButton)
        
        stackView.addArrangedSubview(containerView)
        stackView.addArrangedSubview(buttonContainerView)
        addSubview(stackView)
  
        stackView.pin(to: self)
        
        NSLayoutConstraint.activate([
            // Set up container heights
            buttonContainerView.heightAnchor.constraint(equalToConstant: 44),
            containerView.heightAnchor.constraint(equalToConstant: itemHeight),
            
            // Set up scroll view
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            // Make content view same width as scroll view
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            spinButton.centerXAnchor.constraint(equalTo: buttonContainerView.centerXAnchor),
            spinButton.centerYAnchor.constraint(equalTo: buttonContainerView.centerYAnchor),
            spinButton.heightAnchor.constraint(equalTo: buttonContainerView.heightAnchor),
            spinButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        setupSlotItems()
    }

    private func setupSlotItems() {
        let extendedItems = Array(repeating: recipes, count: 50).flatMap { $0 }
        var previousLabel: UILabel?
        for (_, item) in extendedItems.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = item.name
            label.font = .systemFont(ofSize: 40)
            label.textAlignment = .center
            contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                label.heightAnchor.constraint(equalToConstant: itemHeight),
                label.topAnchor.constraint(equalTo: previousLabel?.bottomAnchor ?? contentView.topAnchor)
            ])
            
            previousLabel = label
        }
        
        if let lastLabel = previousLabel {
            lastLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }

        // Set initial position to the middle set of items
        scrollView.contentOffset.y = CGFloat(recipes.count) * itemHeight
    }
    
    @objc private func spinButtonTapped() {
        guard !isSpinning else { return }
        startSpin()
    }
    
    func startSpin() {
        isSpinning = true
        spinButton.isEnabled = false
        
        let totalDuration: TimeInterval = 3.0
        let initialSpinDuration: TimeInterval = 2.0
        let slowDownDuration: TimeInterval = 0.5
        let finalAdjustmentDuration: TimeInterval = 0.5
        
//        let spinRotations = 3
        let spinDistance = CGFloat(recipes.count * 10) * itemHeight // Spin through 20 sets of items
        let slowDownDistance = CGFloat(recipes.count * 5) * itemHeight
        
        UIView.animateKeyframes(withDuration: totalDuration, delay: 0, options: [.calculationModeCubic], animations: {
            // Fast spin
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: initialSpinDuration / totalDuration) {
                self.scrollView.contentOffset.y += spinDistance
            }
            
            // Slow down
            UIView.addKeyframe(withRelativeStartTime: initialSpinDuration / totalDuration, relativeDuration: slowDownDuration / totalDuration) {
                self.scrollView.contentOffset.y += slowDownDistance
            }
            
            // Final adjustment
            UIView.addKeyframe(withRelativeStartTime: (initialSpinDuration + slowDownDuration) / totalDuration, relativeDuration: finalAdjustmentDuration / totalDuration) {
                let randomIndex = Int.random(in: 0..<self.recipes.count)
                let targetY = (CGFloat(self.recipes.count + randomIndex) * self.itemHeight)
                self.scrollView.contentOffset.y = targetY
            }
        }) { _ in
            self.stopSpin()
        }
    }
    
    func stopSpin() {
        isSpinning = false
        spinButton.isEnabled = true
        
        currentIndex = Int(scrollView.contentOffset.y / itemHeight) % recipes.count
        
        // Ensure the slot view is perfectly aligned
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset.y = CGFloat(self.currentIndex + self.recipes.count) * self.itemHeight
        } completion: { _ in
            self.showResult()
        }
    }
    
    private func showResult() {
        delegate?.showResult(recipes[currentIndex].name ?? "")
    }
}
