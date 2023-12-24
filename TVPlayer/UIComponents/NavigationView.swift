//
//  NavigationView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit

final class NavigationView: UIView {
    var navigationContainer = UIStackView(frame: .zero)
    
    var titleLabel = UILabel()
    var leftButton = UIButton(type: .system)
    var rightButton = UIButton(type: .system)
    
    enum NavigationItem: Hashable {
        case leadingButton(name: String)
        case title(text: String)
        case trailingButton(name: String)
    }
    
    private var tapLeftBotton: (() -> Void)?
    private var tapRightBotton: (() -> Void)?
    
    convenience init(items: Set<NavigationItem>) {
        self.init()
        setupView()
        setupNavigationView(items: items)
        makeConstraints()
    }
    
    func onTapLeftButton(_ onAction: @escaping () -> Void) {
        tapLeftBotton = {
            onAction()
        }
    }
    
    func onTapRightButton(_ onAction: @escaping () -> Void) {
        tapRightBotton = {
            onAction()
        }
    }
    
    private func setupNavigationView(items: Set<NavigationItem>) {
        for item in items {
            switch item {
            case .leadingButton(let name):
                leftButton.setTitle(name, for: .normal)
                leftButton.setTitleColor(Theme.Colors.accent, for: .normal)
            case .title(let text):
                titleLabel.text = text
                titleLabel.textColor = .white
                titleLabel.font = .systemFont(ofSize: 26)
                titleLabel.sizeToFit()
            case .trailingButton(let name):
                rightButton.setTitle(name, for: .normal)
                rightButton.setTitleColor(Theme.Colors.accent, for: .normal)
            }
        }
        
        leftButton.addTarget(self, action: #selector(didTapLeftButton(_:)), for: .touchUpInside)
    }
    
    @objc func didTapLeftButton(_ button: UIButton) {
        tapLeftBotton?()
    }
    
    @objc func didTapRightButton(_ button: UIButton) {
        tapRightBotton?()
    }
    
    private func setupView() {
        self.addSubview(navigationContainer)
        navigationContainer.addArrangedSubview(leftButton)
        navigationContainer.addArrangedSubview(titleLabel)
        navigationContainer.addArrangedSubview(rightButton)
        navigationContainer.axis = .horizontal
        navigationContainer.alignment = .center
        navigationContainer.distribution = .equalSpacing
    }
    
    private func makeConstraints() {
        navigationContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationContainer.topAnchor.constraint(equalTo: topAnchor),
            navigationContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            navigationContainer.leftAnchor.constraint(equalTo: leftAnchor),
            navigationContainer.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
