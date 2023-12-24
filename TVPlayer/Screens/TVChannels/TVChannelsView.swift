//
//  TVChannelView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

protocol TVChannelViewActionsDelegate {
    func didTap(channel:  TVChannel, on segment: TVChannelsView.SegmentsElement)
    func segmentDidChange(to: TVChannelsView.SegmentsElement)
    func tapFavorite(on channel: TVChannel)
}

class TVChannelsView: UIView {
    private let tableView = UITableView(frame: .zero)
    private let navigationView = UIView()
    private let segmentsView = SegmentsView(segments: [SegmentsElement.all.rawValue, SegmentsElement.favorites.rawValue])
    private let divider = UIView()
    
    private var currentSegment: SegmentsElement = .all
    
    var observers: ObservableArray<Observer<TVChannel>> = .init(value: [])
    var actionsDelegate: TVChannelViewActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
        setupTableView()
        subscribe()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func subscribe() {
        segmentsView.onTapSegment { [unowned self] segment in
            currentSegment = SegmentsElement.allCases[segment]
            actionsDelegate?.segmentDidChange(to: currentSegment)
        }
    }
    
    func configure(with observers: ObservableArray<Observer<TVChannel>>) {
        self.observers = observers
    }
    
    func reloadView() {
        tableView.reloadData()
    }
    
    private func setupView() {
        addSubview(navigationView)
        addSubview(tableView)
        navigationView.addSubview(segmentsView)
        navigationView.addSubview(divider)
        
        backgroundColor = Theme.Colors.darkGray
        navigationView.backgroundColor = Theme.Colors.gray
        divider.backgroundColor = Theme.Colors.divider
    }
    
    private func makeConstraints() {
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        segmentsView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Navigation View
            navigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: Constants.navigationHeight),
            navigationView.topAnchor.constraint(equalTo: topAnchor),
            
            // Segments View
            segmentsView.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: Constants.padding),
            segmentsView.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -Constants.padding),
            segmentsView.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: -Constants.segmentsBottomPadding),
            segmentsView.heightAnchor.constraint(equalToConstant: Constants.segmentsHeight),
            
            // Divider
            divider.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(TVChannelCell.self, forCellReuseIdentifier: Constants.cellID)
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.separatorStyle = .none
        tableView.contentInset.top = Constants.tableViewContentOffset
        tableView.setContentOffset(CGPoint(x: 0, y: -Constants.tableViewContentOffset), animated: false)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension TVChannelsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = observers.value[indexPath.row].value
        actionsDelegate?.didTap(channel: channel, on: currentSegment)
    }
}

extension TVChannelsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observers.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath) as! TVChannelCell
        let item = observers.value[indexPath.row].value
        cell.onTapFavoriteButton = { [unowned self] in
            actionsDelegate?.tapFavorite(on: item)
        }
        cell.configureCell(with: item)
        return cell
    }
    
}


// MARK: - Constants
extension TVChannelsView {
    enum Constants {
        static let padding: CGFloat = 16
        static let cellID = "channelCell"
        static let navigationHeight: CGFloat = 120
        static let segmentsHeight: CGFloat = 38
        static let segmentsBottomPadding: CGFloat = 6
        static let dividerHeight: CGFloat = 0.5
        
        static let tableViewRowHeight: CGFloat = 80
        static let tableViewContentOffset: CGFloat = 20
    }
}

// MARK: - Segments
extension TVChannelsView {
    enum SegmentsElement: String, CaseIterable {
        case all = "Все"
        case favorites = "Избранное"
    }
}
