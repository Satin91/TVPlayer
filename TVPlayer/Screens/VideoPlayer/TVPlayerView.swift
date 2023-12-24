//
//  TVPlayerView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 24.12.2023.
//

import UIKit

protocol TVPlayerViewActionsDelegate: AnyObject {
    func navigationBackButtonTap()
}

final class TVPlayerView: UIView {
    var navigationView = NavigationView(items: [.leadingButton(name: "Назад"), .title(text: "Проигрыватель")])

    weak var actionsDelegate: TVPlayerViewActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(navigationView)
        backgroundColor = Theme.Colors.darkGray
    }
    
    func subscribe() {
        navigationView.onTapLeftButton {
            self.actionsDelegate?.navigationBackButtonTap()
        }
        navigationView.onTapRightButton {
         // TODO: - Add tap behaviour
        }
    }
    
    private func makeConstraints() {
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            navigationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            navigationView.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            navigationView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
}
