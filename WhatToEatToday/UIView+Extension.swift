//
//  UIView+Extension.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-08-07.
//

import UIKit

extension UIView {
    
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])   
    }
}
