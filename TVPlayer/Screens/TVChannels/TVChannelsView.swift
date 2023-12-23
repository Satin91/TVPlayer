//
//  TVChannelView.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

protocol TVChannelViewActionsDelegate {
    func didTapChannel()
}

class TVChannelsView: UIView {
    enum Constants {
        static let padding: CGFloat = 16
        static let cellID = "channelCell"
        static let navigationHeight: CGFloat = 120
        static let segmentsHeight: CGFloat = 40
        static let dividerHeight: CGFloat = 0.5
        
        static let tableViewRowHeight: CGFloat = 80
        static let tableViewContentOffset: CGFloat = 20
    }
    
    private let tableView = UITableView(frame: .zero)
    private let navigationView = UIView()
    private let segments = SegmentsView()
    private let divider = UIView()
    
    private var channels: [TVChannel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        makeConstraints()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with channels: [TVChannel]) {
        self.channels = channels
        self.tableView.reloadData()
    }
    
    private func setupView() {
        addSubview(navigationView)
        addSubview(tableView)
        navigationView.addSubview(segments)
        navigationView.addSubview(divider)
        
        backgroundColor = Theme.Colors.darkGray
        navigationView.backgroundColor = Theme.Colors.gray
        divider.backgroundColor = Theme.Colors.divider
    }
    
    private func makeConstraints() {
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        segments.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Navigation View
            navigationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: Constants.navigationHeight),
            navigationView.topAnchor.constraint(equalTo: topAnchor),
            
            // Segments View
            segments.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: Constants.padding),
            segments.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -Constants.padding),
            segments.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor),
            segments.heightAnchor.constraint(equalToConstant: Constants.segmentsHeight),
            
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
        // open video view controller
    }
}

extension TVChannelsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath) as! TVChannelCell
        let item = channels[indexPath.row]
        cell.configureCell(with: item)
        return cell
    }
    
}


extension TVChannelsView {
    
}
