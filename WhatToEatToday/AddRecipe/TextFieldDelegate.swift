//
//  TextFieldDelegate.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-08-08.
//

import Foundation

enum TextFieldTag {
    case name
    case notes
}

protocol TextFieldCellDelegate: AnyObject {
    func textDidChange(for view: TextFieldTag, text: String?)
}
