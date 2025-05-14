//
//  PaddedTextField.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-08-07.
//

import Combine
import UIKit

class PaddedTextField: UITextField {

    private let padding: UIEdgeInsets
    
    lazy var textDidChangePublisher: AnyPublisher<String, Never> = {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }()

    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
        layer.cornerRadius = 8
        layer.borderWidth = 0.6
        layer.borderColor = UIColor.black.cgColor
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    func setEditable(_ editable: Bool) {
        isEnabled = editable
        backgroundColor = editable ? .systemBackground : .systemGray6
    }
}
