//
//  TVChannelView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

protocol TVChannelViewActionsDelegate: AnyObject {
    func didTap(on channel: TVChannel)
    func segmentDidChange(to: TVChannelsModel.SegmentsElement)
    func tapFavorite(channel: TVChannel)
    func searchChannel(by text: String)
}

class TVChannelsView: UIView {
    private let tableView = UITableView(frame: .zero)
    private let navigationView = UIView()
    private let segmentsView = SegmentsView(
        segments: [
            TVChannelsModel.SegmentsElement.all.rawValue,
            TVChannelsModel.SegmentsElement.favorites.rawValue]
    )
    private let divider = UIView()
    private let searchBar = SearchBar()
    private var currentSegment: TVChannelsModel.SegmentsElement = .all
    
    weak var actionsDelegate: TVChannelViewActionsDelegate?
    
    var dynamicChannels = Observable<[TVChannel]>([])
    
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
            currentSegment = TVChannelsModel.SegmentsElement.allCases[segment]
            actionsDelegate?.segmentDidChange(to: currentSegment)
        }
        
        searchBar.searchText.subscribe { [unowned self] text in
            actionsDelegate?.searchChannel(by: text)
        }
        
        dynamicChannels.subscribe { channels in
            print("reload view")
            self.reloadView()
        }
    }
    
    func reloadView() {
        tableView.reloadData()
    }
}

extension TVChannelsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = dynamicChannels.value[indexPath.row]
        actionsDelegate?.didTap(on: channel)
    }
}

extension TVChannelsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicChannels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath) as! TVChannelCell
        let item = dynamicChannels.value[indexPath.row]
        cell.onTapFavoriteButton = { [unowned self] in
            actionsDelegate?.tapFavorite(channel: item)
        }
        cell.configureCell(with: item)
        return cell
    }
    
}

// MARK: - Setup View
extension TVChannelsView {
    enum Constants {
        static let padding: CGFloat = 16
        static let cellID = "channelCell"
        static let navigationHeight: CGFloat = 180
        static let segmentsHeight: CGFloat = 38
        static let segmentsBottomPadding: CGFloat = 6
        static let dividerHeight: CGFloat = 0.5
        
        static let tableViewRowHeight: CGFloat = 80
        static let tableViewContentOffset: CGFloat = 20
    }
    
    private func setupView() {
        addSubview(navigationView)
        addSubview(tableView)
        navigationView.addSubview(segmentsView)
        navigationView.addSubview(divider)
        navigationView.addSubview(searchBar)
        
        
        backgroundColor = Theme.Colors.darkGray
        navigationView.backgroundColor = Theme.Colors.gray
        divider.backgroundColor = Theme.Colors.divider
    }
    
    private func makeConstraints() {
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        segmentsView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Navigation View
            navigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: Constants.navigationHeight),
            navigationView.topAnchor.constraint(equalTo: topAnchor),
            
            searchBar.topAnchor.constraint(equalTo: navigationView.topAnchor, constant: 80),
            searchBar.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -24),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
            
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
            tableView.widthAnchor.constraint(equalTo: widthAnchor),
            
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
    }
}
