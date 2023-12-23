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
    let underLine = UIView()
    var underlineLeadingConstraint = NSLayoutConstraint()
    var underlineWidthConstraint = NSLayoutConstraint()
    
    var onTapSegment: ((Int) -> Void)?
    
    convenience init(segments: [String]) {
        self.init()
        self.segments = segments
        setupView()
        createSegments()
        makeConstraints()
    }
    
    private func setupView() {
        addSubview(segmentsStackView)
        addSubview(underLine)
        underLine.backgroundColor = Theme.Colors.accent
        segmentsStackView.axis = .horizontal
        segmentsStackView.distribution = .fillProportionally
        segmentsStackView.alignment = .leading
        segmentsStackView.spacing = 16
    }
    
    private func makeConstraints() {
        segmentsStackView.translatesAutoresizingMaskIntoConstraints = false
        underLine.translatesAutoresizingMaskIntoConstraints = false
        
        let firstSegment = segmentsStackView.arrangedSubviews[0] as? SegmentButton
        
        underlineWidthConstraint = underLine.widthAnchor.constraint(equalToConstant: firstSegment?.buttomWidth ?? .zero)
        underlineLeadingConstraint = underLine.leadingAnchor.constraint(equalTo: leadingAnchor)
        
        NSLayoutConstraint.activate([
            segmentsStackView.topAnchor.constraint(equalTo: topAnchor),
            segmentsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentsStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            segmentsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            underlineWidthConstraint,
            underlineLeadingConstraint,
            underLine.heightAnchor.constraint(equalToConstant: 2),
            underLine.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func animateView(index: Int) {
        guard let buttons = segmentsStackView.arrangedSubviews as? [SegmentButton] else { return }
        onTapSegment?(index)
        underlineWidthConstraint.constant = buttons[index].buttomWidth
        underlineLeadingConstraint.constant = buttons[index].frame.origin.x
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
            buttons.forEach { $0.isSelected($0.tag == index) }
        }
    }
    
    private func createSegments() {
        for (index, segmentName) in segments.enumerated() {
            let segment = SegmentButton(text: segmentName)
            segment.tag = index
            segment.addTarget(self, action: #selector(segmentTapped), for: .touchUpInside)
            segment.isSelected(index == 0)
            segmentsStackView.addArrangedSubview(segment)
        }
    }
    
    @objc func segmentTapped(_ button: SegmentButton) {
        animateView(index: button.tag)
    }
}

class SegmentButton: UIButton {
    
    private let labelPadding: CGFloat = 16 * 2
    
    public var buttomWidth: CGFloat {
        guard let width = titleLabel?.intrinsicContentSize.width else { return 0 }
        return width + labelPadding
    }
    
    func isSelected(_ selected: Bool) {
        self.layer.opacity = selected ? 1 : 0.5
    }
    
    convenience init(text: String) {
        self.init()
        self.setTitle(text, for: .normal)
        makeConstraints()
    }
    
    private func makeConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: buttomWidth).isActive = true
    }
}
