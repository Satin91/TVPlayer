//
//  PlayButton.swift
//  TVPlayer
//
//  Created by Артур Кулик on 29.12.2023.
//

import UIKit

class PlayButton: UIView {
    
    enum Constants {
        static let iconPadding: CGFloat = 18
        static let tapAnimationDuration: CGFloat = 0.1
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let playButtonShape = PlayButtonShape()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
        playButtonShape.configure(with: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(playState: Bool) {
        playButtonShape.configure(with: true)
    }
    
    private func setupView() {
        addSubview(blurEffectView)
        addSubview(playButtonShape)
        playButtonShape.animationDuration = Constants.tapAnimationDuration
        blurEffectView.alpha = 0.8
    }
    
    public func buttonTapped(_ isPlay: Bool) {
        UIView.animate(withDuration: Constants.tapAnimationDuration) {
            self.playButtonShape.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            self.playButtonShape.animate()
            UIView.animate(withDuration: Constants.tapAnimationDuration) {
                self.playButtonShape.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    private func makeConstraints() {
        playButtonShape.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButtonShape.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.iconPadding),
            playButtonShape.topAnchor.constraint(equalTo: topAnchor, constant: Constants.iconPadding),
            playButtonShape.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.iconPadding),
            playButtonShape.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.iconPadding),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurEffectView.frame = bounds
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
    }
}

fileprivate final class PlayButtonShape: UIView {
    public var animationDuration: CGFloat = 0.3
    
    private var playState = false
    
    private let radius: CGFloat = 4
    private let rectWidth: CGFloat = 10
    private var spacing: CGFloat {
        rectWidth
    }
    private let rightFigure: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    private let leftFigure: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    private var leftRect: CGMutablePath {
        drawRect(leftX: bounds.midX - spacing / 2 - rectWidth, rightX: bounds.midX - spacing / 2, radius: radius, topPadding: spacing / 2)
    }
    
    private var rightRect: CGMutablePath {
        drawRect(leftX: bounds.midX + spacing / 2, rightX: bounds.midX + spacing / 2 + rectWidth, radius: radius, topPadding: spacing / 2)
    }
    
    private var triangle: CGMutablePath {
        return drawTriangle()
    }
    
    private var zeroPath: CGMutablePath {
        drawRect(leftX: bounds.midX + spacing / 2, rightX: spacing + 0.5, radius: 0.25, topPadding: 15)
    }
    
    public func configure(with: Bool) {
        playState = with
        leftFigure.path = playState ? leftRect : triangle
        rightFigure.path = playState ? rightRect : zeroPath
    }
    
    public func animate() {
        playState.toggle()
        let rightReverseAnimation = CABasicAnimation(keyPath: "path")
        rightReverseAnimation.duration = animationDuration
        rightReverseAnimation.fromValue = playState == false ? rightRect : zeroPath
        rightReverseAnimation.toValue = playState == false ? zeroPath : rightRect
        rightReverseAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        rightFigure.removeAnimation(forKey: "animateTriangle")
        rightFigure.add(rightReverseAnimation, forKey: "animateTriangle")
        
        let leftReverseAnimation = CABasicAnimation(keyPath: "path")
        leftReverseAnimation.duration = animationDuration
        leftReverseAnimation.fromValue = playState == false ? leftRect : triangle
        leftReverseAnimation.toValue = playState == false ? triangle : leftRect
        leftReverseAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        leftFigure.removeAnimation(forKey: "animateRect")
        leftFigure.add(leftReverseAnimation, forKey: "animateRect")
        
        if playState {
            rightFigure.path = rightRect
            leftFigure.path = leftRect
        } else {
            rightFigure.path = zeroPath
            leftFigure.path = triangle
        }
    }
    
    private func drawTriangle() -> CGMutablePath {
        let path = CGMutablePath()
        let padding: CGFloat = 6
        
        let topLeft = CGPoint(x: padding, y: .zero)
        let middleLeft = CGPoint(x: padding, y: bounds.midY)
        let middleRight = CGPoint(x: bounds.maxX, y: bounds.midX)
        let bottomLeft = CGPoint(x: padding, y: bounds.height)
        
        path.move(to: middleLeft)
        path.addArc(tangent1End: topLeft, tangent2End: middleRight, radius: radius)
        path.addArc(tangent1End: middleRight, tangent2End: bottomLeft, radius: radius)
        path.addArc(tangent1End: bottomLeft, tangent2End: topLeft, radius: radius)
        path.closeSubpath()
        return path
    }
    
    private func drawRect(leftX: CGFloat, rightX: CGFloat, radius: CGFloat, topPadding: CGFloat = 0) -> CGMutablePath {
        let path = CGMutablePath()
        
        let middleLeft = CGPoint(x: leftX, y: bounds.midY)
        let topLeft = CGPoint(x: leftX, y: topPadding)
        let topRight = CGPoint(x: rightX, y: topPadding)
        let bottomLeft = CGPoint(x: leftX, y: bounds.height - topPadding)
        let bottomRight = CGPoint(x: rightX, y: bounds.height - topPadding)
        
        path.move(to: middleLeft)
        path.addArc(tangent1End: topLeft, tangent2End: topRight, radius: radius)
        path.addArc(tangent1End: topRight, tangent2End: bottomRight, radius: radius)
        path.addArc(tangent1End: bottomRight, tangent2End: bottomLeft, radius: radius)
        path.addArc(tangent1End: bottomLeft, tangent2End: topLeft, radius: radius)
        path.closeSubpath()
        return path
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(leftFigure)
        layer.addSublayer(rightFigure)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configure(with: playState)
    }
}
