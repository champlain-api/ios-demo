//
// AnnouncementsView.swift
// Champlain API Demo
//
//
// some code adapted from https://developer.apple.com/documentation/uikit/implementing-modern-collection-views
// and Copyright © 2024 Apple Inc.

import UIKit

class AnnouncementsView: UIViewController {

    enum Section {
        case main
    }

    var viewModel: AnnouncementViewModel

    var dataSource: UICollectionViewDiffableDataSource<Section, Announcement>! = nil
    var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentUnavailableConfiguration = nil
        configureHierarchy()
        configureDataSource()
        self.collectionView.reloadData()
        navigationItem.title = "Announcements"
        if viewModel.announcements.count == 0 {
            var empty = UIContentUnavailableConfiguration.empty()
            empty.text = "No Announcements"
            empty.secondaryText = "There are currently no announcements."
            empty.image = UIImage(systemName: "slash.circle")

            self.contentUnavailableConfiguration = empty
            return
        }

    }
    init(viewModel: AnnouncementViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AnnouncementsView {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension AnnouncementsView {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    private func configureDataSource() {

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Announcement> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.secondaryText = item.description
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Announcement>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Announcement) -> UICollectionViewCell? in

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Announcement>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.announcements)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension AnnouncementsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
