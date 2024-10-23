//
//  RecipeNotesCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import UIKit

class RecipeNotesCell: UITableViewCell, UITextViewDelegate {
    
    static let identifier = "RecipeNotesCell"
    
    let placeHolderText = "Please enter any additional notes here..."
    
    lazy var notesView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.text = placeHolderText
        return textView
    }()
    
    weak var delegate: TextFieldCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupBorder()
        contentView.addSubview(notesView)
        
        notesView.delegate = self
        NSLayoutConstraint.activate([
            notesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            notesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            notesView.topAnchor.constraint(equalTo: contentView.topAnchor),
            notesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupBorder() {
        notesView.layer.cornerRadius = 8
        notesView.layer.borderWidth = 0.6
        notesView.layer.borderColor = UIColor.black.cgColor
        notesView.layer.masksToBounds = true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = nil
        }
        addDoneButtonKeyboard(for: textView)
    }
    
    func addDoneButtonKeyboard(for textView: UITextView) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        textView.inputAccessoryView = toolbar
    }
    
    @objc
    private func dismissKeyboard() {
        notesView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
        }
        if textView.text != placeHolderText {
            delegate?.textDidChange(for: .notes, text: textView.text)
        }
    }
    
    func configure(with text: String?) {
        notesView.text = text
    }
}
