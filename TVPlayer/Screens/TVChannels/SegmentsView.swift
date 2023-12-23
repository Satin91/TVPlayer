//
//  SegmentsView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

class SegmentsView: UIView {
    
    var segments = ["Все", "Избранное"]
    var segmentsStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        createSegments()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(segmentsStackView)
        segmentsStackView.translatesAutoresizingMaskIntoConstraints = false
        segmentsStackView.axis = .horizontal
        segmentsStackView.distribution = .fillProportionally
        segmentsStackView.alignment = .leading
        segmentsStackView.spacing = 16
        
        NSLayoutConstraint.activate([
            segmentsStackView.topAnchor.constraint(equalTo: topAnchor),
            segmentsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentsStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            segmentsStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func createSegments() {
        for segmentName in segments {
            let segment = SegmentButton()
            segment.setTitle(segmentName, for: .normal)
            segmentsStackView.addArrangedSubview(segment)
        }
    }
}

class SegmentButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        setTitleColor(.white, for: .normal)
        setTitleColor(.systemRed, for: .highlighted)
        setTitleColor(.systemBlue, for: .focused)
        setTitleColor(.systemOrange, for: .selected)
    }
}
