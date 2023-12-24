//
//  TVChannelView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

protocol TVChannelViewActionsDelegate: AnyObject {
    func didTap(on row: Int, on segment: TVChannelsView.SegmentsElement)
    func segmentDidChange(to: TVChannelsView.SegmentsElement)
    func tapFavorite(on row: Int, on segment: TVChannelsView.SegmentsElement)
}

class TVChannelsView: UIView {
    private let tableView = UITableView(frame: .zero)
    private let navigationView = UIView()
    private let segmentsView = SegmentsView(segments: [SegmentsElement.all.rawValue, SegmentsElement.favorites.rawValue])
    private let divider = UIView()
    private let activityIndicator = UIActivityIndicatorView(frame: .zero)
    
    private var currentSegment: SegmentsElement = .all
    
    weak var actionsDelegate: TVChannelViewActionsDelegate?
    
    var dynamicChannels = Observable<[TVChannel]>([])
    private var viewState: Bool = false
    
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
        actionsDelegate?.didTap(on: indexPath.row, on: currentSegment)
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
            actionsDelegate?.tapFavorite(on: indexPath.row, on: currentSegment)
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
        static let navigationHeight: CGFloat = 120
        static let segmentsHeight: CGFloat = 38
        static let segmentsBottomPadding: CGFloat = 6
        static let dividerHeight: CGFloat = 0.5
        
        static let tableViewRowHeight: CGFloat = 80
        static let tableViewContentOffset: CGFloat = 20
    }
    
    enum SegmentsElement: String, CaseIterable {
        case all = "Все"
        case favorites = "Избранное"
    }
    
    private func setupView() {
        addSubview(navigationView)
        addSubview(tableView)
        addSubview(activityIndicator)
        navigationView.addSubview(segmentsView)
        navigationView.addSubview(divider)
        
        backgroundColor = Theme.Colors.darkGray
        navigationView.backgroundColor = Theme.Colors.gray
        divider.backgroundColor = Theme.Colors.divider
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.style = UIActivityIndicatorView.Style.white
    }
    
    private func makeConstraints() {
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        segmentsView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isHidden = true
        
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
            tableView.widthAnchor.constraint(equalTo: widthAnchor),
            
            // Activity Indicator
//            activityIndicator.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
//            activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
//            activityIndicator.widthAnchor.constraint(equalTo: widthAnchor)
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
