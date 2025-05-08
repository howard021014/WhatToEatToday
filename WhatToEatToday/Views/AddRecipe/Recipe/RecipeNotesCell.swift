//
//  RecipeNotesCell.swift
//  What2EatToday
//
//  Created by Howard tsai on 2024-07-28.
//

import Combine
import UIKit

class RecipeNotesCell: UITableViewCell, UITextViewDelegate, EditableCell {
    
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
    
    lazy var textPublisher: AnyPublisher<String, Never> = {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: notesView)
            .compactMap { ($0.object as? UITextView)?.text }
            .eraseToAnyPublisher()
    }()

    private var cancellables = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupBorder()
        addDoneButtonKeyboard(for: notesView)
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
    
    func bind(to viewModel: RecipeFormViewModel) {
        // Emits the text and assign to view model (UI -> VM)
        textPublisher
            .receive(on: RunLoop.main)
            .sink { [weak viewModel] text in
                viewModel?.draft.recipeNotes = text
            }
            .store(in: &cancellables)

        // Toggles the editable state based on view model (VM -> UI)
        viewModel.$isEditable
            .receive(on: RunLoop.main)
            .sink { [weak self] editable in
                self?.setEditable(editable)
            }
            .store(in: &cancellables)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText {
            textView.text = ""
        }
    }
    
    func addDoneButtonKeyboard(for textView: UITextView) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
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
    }

    func setEditable(_ editable: Bool) {
        notesView.isEditable = editable
        notesView.backgroundColor = editable ? .systemBackground : .systemGray6
    }
}
