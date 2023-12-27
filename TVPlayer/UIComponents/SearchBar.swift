//
//  TextField.swift
//  TVPlayer
//
//  Created by Артур Кулик on 27.12.2023.
//

import UIKit

class SearchBar: UIView {
    private let textField = UITextField()
    private let imageView = UIImageView()
    
    var searchText = Observable("")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(textField)
        addSubview(imageView)
        imageView.image = Theme.Images.search
        textField.textColor = Theme.Colors.lightGray
        textField.delegate = self
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Напишите название канала",
            attributes: [NSAttributedString.Key.foregroundColor: Theme.Colors.lightGray]
        )
        
        backgroundColor = Theme.Colors.textFieldBG
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    
    
    private func makeConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

extension SearchBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText.send(textField.text ?? "")
        return true
    }
}
