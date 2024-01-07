//
//  Slider.swift
//  TVPlayer
//
//  Created by Артур Кулик on 25.12.2023.
//

import UIKit

final class Slider: UIView {
    
    private var track = UIView()
    private var trackConstraint = NSLayoutConstraint()
    let gradientlayer = CAGradientLayer()
    let label = UILabel()
    var frameWidth: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
                setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(track)
        
        backgroundColor = Theme.Colors.gray
        track.backgroundColor = Theme.Colors.accent
        gradientlayer.type = .axial
        gradientlayer.colors = [Theme.Colors.accent?.cgColor, Theme.Colors.mint?.cgColor]
        gradientlayer.startPoint = CGPoint(x: 0, y: 1)
        gradientlayer.endPoint = CGPoint(x: 1, y: 1)
        track.layer.addSublayer(gradientlayer)
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        self.addGestureRecognizer(dragGesture)
    }
    
    let mainLabel = UILabel()
    let maskLabel = UILabel()
    
    func sliderDidEndMove(_ handler: @escaping (CGFloat) -> Void) {
        sliderDidEndMoveClosure = {
            handler($0)
        }
    }
    
    func sliderDidMove(onChange: @escaping (CGFloat) -> Void) {
        sliderDidMoveClosure = {
            onChange($0)
        }
    }
    
    private var sliderDidMoveClosure: ((CGFloat) -> Void)?
    private var sliderDidEndMoveClosure: ((CGFloat) -> Void)?
    
    @objc private func drag(_ gesture: UIPanGestureRecognizer) {
        var velocity = gesture.velocity(in: self)
        let range = (min: -frameWidth, max: CGFloat(0))
        var constraintValue = trackConstraint.constant + (velocity.x / 100)
        let sliderValue = (track.frame.width / frame.width) * 100
        
        if constraintValue > range.max {
            constraintValue = range.max
        } else if constraintValue < range.min {
            constraintValue = range.min
        }
        trackConstraint.constant = constraintValue
        sliderDidMoveClosure?(sliderValue)
        
        if gesture.state == .ended {
            sliderDidEndMoveClosure?(sliderValue)
        }
    }
    
    func setupConstraints() {
        track.translatesAutoresizingMaskIntoConstraints = false
        trackConstraint = track.trailingAnchor.constraint(equalTo: trailingAnchor)
        
        NSLayoutConstraint.activate([
            track.topAnchor.constraint(equalTo: topAnchor),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackConstraint,
        ])
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return bounds.insetBy(dx: -10, dy: -10).contains(point)
        }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientlayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
        track.layer.cornerRadius = track.bounds.height / 2
        track.layer.masksToBounds = true
        self.frameWidth = bounds.width
    }
}
