//
//  ContextMenu.swift
//  TVPlayer
//
//  Created by Артур Кулик on 26.12.2023.
//

import UIKit

final class ContextMenu: UIView {
    private var contextElements: [ContextElement] = []
    private var contextContainer = UIStackView()
    private var tapClosure: ((Int) -> Void)?
    
    private var onDisplay = false
    
    
    convenience init(elements: [String]) {
        self.init()
        configure(with: elements)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
    }
    
    func show() {
        UIView.animate(withDuration: 0.4, delay: .zero, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
            self.transform = CGAffineTransformMakeScale(1,1)
            self.layer.opacity = 1
        }
        onDisplay.toggle()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.4, delay: .zero, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
            self.transform = CGAffineTransformMakeScale(0.8,0.8)
            self.layer.opacity = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with elements: [String]) {
        for (index, text) in elements.enumerated() {
            let contextElement = ContextElement(text: text)
            contextElement.tag = index
            contextElement.addTarget(self, action: #selector(elementTapped(_:)), for: .touchUpInside)
            contextContainer.addArrangedSubview(contextElement)
            NSLayoutConstraint.activate([
                contextElement.leadingAnchor.constraint(equalTo: leadingAnchor),
                contextElement.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }
    }
    
    func didTapElement(_ handler: @escaping (Int) -> Void) {
        tapClosure = {
            handler($0)
        }
    }
    
    @objc private func elementTapped(_ element: ContextElement) {
        let index = element.tag
        tapClosure?(index)
        
        let element = contextContainer.arrangedSubviews[index] as? ContextElement
        element?.animateTap()
    }
    
    func setupView() {
        addSubview(contextContainer)
        contextContainer.axis = .vertical
        contextContainer.alignment = .center
        contextContainer.distribution = .fillEqually
        contextContainer.backgroundColor = .white
        transform = CGAffineTransformMakeScale(0.7,0.7)
        layer.opacity = 0
    }
    
    func makeConstraints() {
        contextContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contextContainer.topAnchor.constraint(equalTo: topAnchor),
            contextContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            contextContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contextContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

final class ContextElement: UIButton {
    
    private var divider = UIView()
    private let textColor = UIColor.black.withAlphaComponent(0.8)
    private let animatedTextColor = UIColor.white
    
    let dividerHeight: CGFloat = 0.5
    
    convenience init(text: String) {
        self.init()
        configure(with: text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        setTitle(text, for: .normal)
        setTitleColor(textColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    private func setupView() {
        addSubview(divider)
        divider.backgroundColor = Theme.Colors.contextDivider
    }
    
    func animateTap() {
        backgroundColor = Theme.Colors.accent
        setTitleColor(animatedTextColor, for: .normal)
        UIView.animate(withDuration: 0.5) {
            self.setTitleColor(self.textColor, for: .normal)
            self.backgroundColor = .clear
        }
    }
    
    private func makeConstraints() {
        divider.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: dividerHeight),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
