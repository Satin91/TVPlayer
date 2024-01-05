//
//  PlayButton.swift
//  TVPlayer
//
//  Created by Артур Кулик on 29.12.2023.
//

import UIKit

class PlayButton: UIView {
    
    enum Constants {
        static let imagePadding: CGFloat = 14
        static let tapAnimationDuration: CGFloat = 0.05
    }
    
    private var isPlay = false
    private var playImage = Theme.Images.play
    private var pauseImage = Theme.Images.pause
    private let imageView = UIImageView()
    
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    let shape = PlayAnimation()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        //        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isPlay.toggle()
    }
    
    public func setState(_ isPlay: Bool) {
        shape.tap()
        UIView.animate(withDuration: Constants.tapAnimationDuration) {
            self.imageView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        } completion: { _ in
            self.imageView.image = isPlay ? self.pauseImage : self.playImage
            UIView.animate(withDuration: Constants.tapAnimationDuration, delay: .zero, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) {
                self.imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    private func setupView() {
        playImage = playImage.withRenderingMode(.alwaysTemplate)
        pauseImage = pauseImage.withRenderingMode(.alwaysTemplate)
        addSubview(shape)
        
        //        addSubview(blurEffectView)
        //        addSubview(imageView)
        //        backgroundColor = .systemRed
        //        tintColor = .white
        backgroundColor = .mint
    }
    
    private func tapped() {
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.layer.opacity = 0
            }
        }
    }
    
    private func makeConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.imagePadding),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.imagePadding),
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.imagePadding),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.imagePadding)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurEffectView.frame = bounds
        layer.cornerRadius = bounds.width / 2
        layer.masksToBounds = true
        shape.frame = CGRect(x: 12, y: 12, width: bounds.width - 24, height: bounds.height - 24)
        
    }
}

final class PlayAnimation: UIView {
    
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var animateState = true
    
    let animationDuration: CGFloat = 1
    
    private let radius: CGFloat = 5
    private let rectWidth: CGFloat = 12
    private let rectSpacing: CGFloat = 20
    
    private let rightFigure: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    private let leftFigure: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        return shapeLayer
    }()
    
    var leftRect: CGMutablePath {
        drawRect(leftX: .zero, rightX: rectWidth, radius: radius)
    }
    
    var rightRect: CGMutablePath {
        drawRect(leftX: rectWidth + rectSpacing, rightX: rectWidth + rectSpacing + rectWidth, radius: radius)
    }
    
    var triangle: CGMutablePath {
        return drawTriangle()
    }
    
    public func tap() {
        startTime = CACurrentMediaTime()
        animateState.toggle()
        
        let rightReverseAnimation = CABasicAnimation(keyPath: "path")
        rightReverseAnimation.duration = animationDuration
        rightReverseAnimation.fromValue = animateState == false ? rightRect : triangle
        rightReverseAnimation.toValue = animateState == false ? triangle : rightRect
        rightReverseAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        rightReverseAnimation.isRemovedOnCompletion = false
        rightReverseAnimation.fillMode = .backwards
        rightFigure.removeAnimation(forKey: "animateCard")
        rightFigure.add(rightReverseAnimation, forKey: "animateCard")
//        CATransaction.commit()
        
        let leftReverseAnimation = CABasicAnimation(keyPath: "path")
        leftReverseAnimation.duration = animationDuration
        leftReverseAnimation.fromValue = animateState == false ? leftRect : leftZeroPath()
        leftReverseAnimation.toValue = animateState == false ? leftZeroPath() : leftRect
        leftReverseAnimation.timingFunction = CAMediaTimingFunction(name: .default)
        leftReverseAnimation.isRemovedOnCompletion = false
        leftReverseAnimation.fillMode = .backwards
        leftFigure.removeAnimation(forKey: "animateCard2")
        leftFigure.add(leftReverseAnimation, forKey: "animateCard2")
//        CATransaction.commit()
        
        if animateState {
            rightFigure.path = rightRectPath()
            leftFigure.path = leftRect
        } else {
            rightFigure.path = drawTriangle()
            leftFigure.path = leftZeroPath()
        }
    }
    
    private func leftZeroPath() -> CGMutablePath {
        drawRect(leftX: .zero, rightX: 0.5, radius: 0)
    }
    
    private func leftRectPath() -> CGMutablePath {
        let leftX: CGFloat = 0
        let rightX = rectWidth
        let path = CGMutablePath()
        
        let middleLeft = CGPoint(x: leftX, y: bounds.midY)
        let topLeft = CGPoint(x: leftX, y: .zero)
        let topRight = CGPoint(x: rightX, y: .zero)
        let bottomLeft = CGPoint(x: leftX, y: bounds.height)
        let bottomRight = CGPoint(x: rightX, y: bounds.height)
        
        path.move(to: middleLeft)
        
        path.addArc(tangent1End: topLeft, tangent2End: topRight, radius: radius)
        path.addArc(tangent1End: topRight, tangent2End: bottomRight, radius: radius)
        path.addArc(tangent1End: bottomRight, tangent2End: bottomLeft, radius: radius)
        path.addArc(tangent1End: bottomLeft, tangent2End: topLeft, radius: radius)
        path.closeSubpath()
        return path
    }
    
    private func rightRectPath() -> CGMutablePath {
        let leftX = rectWidth + rectSpacing
        let rightX = rectSpacing + rectWidth + rectWidth
        let path = CGMutablePath()
        
        let middleLeft = CGPoint(x: leftX, y: bounds.midY)
        let topLeft = CGPoint(x: leftX, y: .zero)
        let topRight = CGPoint(x: rightX, y: .zero)
        let bottomLeft = CGPoint(x: leftX, y: bounds.height)
        let bottomRight = CGPoint(x: rightX, y: bounds.height)
        
        path.move(to: middleLeft)
        
        path.addArc(tangent1End: topLeft, tangent2End: topRight, radius: radius)
        path.addArc(tangent1End: topRight, tangent2End: bottomRight, radius: radius)
        path.addArc(tangent1End: bottomRight, tangent2End: bottomLeft, radius: radius)
        path.addArc(tangent1End: bottomLeft, tangent2End: topLeft, radius: radius)
        path.closeSubpath()
        
        return path
    }
    
    private func drawTriangle() -> CGMutablePath {
        let path = CGMutablePath()
        let height = bounds.height
        
        // The triangle's three corners.
        let topLeft = CGPoint(x: 0, y: 0)
        let middleLeft = CGPoint(x: .zero, y: bounds.midY)
        let middleRight = CGPoint(x: bounds.maxX, y: bounds.midX)
        let bottomLeft = CGPoint(x: 0, y: height)
        
        // Draw three arcs to trace the triangle.
        path.move(to: middleLeft)
        path.addArc(tangent1End: topLeft, tangent2End: middleRight, radius: radius)
        path.addArc(tangent1End: middleRight, tangent2End: bottomLeft, radius: radius)
        path.addArc(tangent1End: bottomLeft, tangent2End: topLeft, radius: radius)
        path.closeSubpath()
        return path
    }
    
    private func drawRect(leftX: CGFloat, rightX: CGFloat, radius: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        
        let middleLeft = CGPoint(x: leftX, y: bounds.midY)
        let topLeft = CGPoint(x: leftX, y: .zero)
        let topRight = CGPoint(x: rightX, y: .zero)
        let bottomLeft = CGPoint(x: leftX, y: bounds.height)
        let bottomRight = CGPoint(x: rightX, y: bounds.height)
        
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
        layer.addSublayer(rightFigure)
        layer.addSublayer(leftFigure)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
