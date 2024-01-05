//
//  PlayButton.swift
//  TVPlayer
//
//  Created by Артур Кулик on 29.12.2023.
//

import UIKit

class PlayButton: UIView {
    
    enum Constants {
        static let iconPadding: CGFloat = 14
        static let tapAnimationDuration: CGFloat = 0.1
    }
    
    private var isPlay = false
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private let playButtonShape = PlayButtonShape()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isPlay.toggle()
    }
    
    public func setState(_ isPlay: Bool) {
        playButtonShape.animate()
        UIView.animate(withDuration: Constants.tapAnimationDuration) {
            self.playButtonShape.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: Constants.tapAnimationDuration) {
                self.playButtonShape.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    private func setupView() {
        addSubview(blurEffectView)
        addSubview(playButtonShape)
        playButtonShape.animationDuration = Constants.tapAnimationDuration
    }
    
    private func tapped() {
        UIView.animate(withDuration: Constants.tapAnimationDuration / 2) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: Constants.tapAnimationDuration / 2) {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
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
    public var initialState = false
    
    private var startTime: CFTimeInterval = 0
    
    private var animateState = true
    
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
        drawRect(leftX: spacing, rightX: spacing + 0.5, radius: 0.25, topPadding: spacing + radius + 2)
    }
    
    public func animate() {
        startTime = CACurrentMediaTime()
        animateState.toggle()
        print("Animate state \(animateState)")
        let rightReverseAnimation = CABasicAnimation(keyPath: "path")
        rightReverseAnimation.duration = animationDuration
        rightReverseAnimation.fromValue = animateState == false ? rightRect : triangle
        rightReverseAnimation.toValue = animateState == false ? triangle : rightRect
        rightReverseAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        rightFigure.removeAnimation(forKey: "animateTriangle")
        rightFigure.add(rightReverseAnimation, forKey: "animateTriangle")
        
        let leftReverseAnimation = CABasicAnimation(keyPath: "path")
        leftReverseAnimation.duration = animationDuration
        leftReverseAnimation.fromValue = animateState == false ? leftRect : zeroPath
        leftReverseAnimation.toValue = animateState == false ? zeroPath : leftRect
        leftReverseAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        leftFigure.removeAnimation(forKey: "animateRect")
        leftFigure.add(leftReverseAnimation, forKey: "animateRect")
        
        if animateState {
            rightFigure.path = rightRect
            leftFigure.path = leftRect
        } else {
            rightFigure.path = triangle
            leftFigure.path = zeroPath
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
        leftFigure.path = leftRect
        rightFigure.path = rightRect
    }
}
