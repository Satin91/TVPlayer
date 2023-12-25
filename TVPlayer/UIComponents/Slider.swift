//
//  Slider.swift
//  TVPlayer
//
//  Created by Артур Кулик on 25.12.2023.
//

import UIKit

final class Slider: UIView {
    
    private var lineMask = UIView()
    private var dragValue: CGFloat = 0
    private var filledLineConstraint = NSLayoutConstraint()
    let gradientlayer = CAGradientLayer()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
                setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(lineMask)
        
        backgroundColor = Theme.Colors.gray
        lineMask.backgroundColor = Theme.Colors.accent
        gradientlayer.type = .axial
        gradientlayer.colors = [Theme.Colors.accent!.cgColor, UIColor.white.cgColor]
        gradientlayer.startPoint = CGPoint(x: 0, y: 1)
        gradientlayer.endPoint = CGPoint(x: 1, y: 1)
        lineMask.layer.addSublayer(gradientlayer)
        
//        lineMask.layer.mask = gradientlayer
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        self.addGestureRecognizer(dragGesture)
    }
    
    let mainLabel = UILabel()
    let maskLabel = UILabel()
    
    @objc private func drag(_ gesture: UIPanGestureRecognizer) {
        print("change constraint \(lineMask.frame.width)")
        let velocity = gesture.velocity(in: self)
        
        print(filledLineConstraint.constant)
        if !lineMask.frame.contains(velocity) {
            filledLineConstraint.constant += velocity.x / 100
        }
    }
    
    func setupConstraints() {
        lineMask.translatesAutoresizingMaskIntoConstraints = false
        filledLineConstraint = lineMask.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        NSLayoutConstraint.activate([
            lineMask.topAnchor.constraint(equalTo: topAnchor),
            lineMask.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineMask.leadingAnchor.constraint(equalTo: leadingAnchor),
            filledLineConstraint,
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientlayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
        lineMask.layer.cornerRadius = lineMask.bounds.height / 2
        lineMask.layer.masksToBounds = true
    }
}
