//
// AnnouncementsView.swift
// Champlain API Demo
//
//
// some code adapted from https://developer.apple.com/documentation/uikit/implementing-modern-collection-views

import UIKit

class AnnouncementsView: UIViewController {

    enum Section {
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Announcement>! = nil
    var collectionView: UICollectionView! = nil
    let vm = AnnouncementViewModel.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        Task {
            // TODO: check if failed request
            try? await vm.fetchData()
            configureDataSource()
            self.collectionView.reloadData()
        }
        navigationItem.title = "Announcements"
    }

    init() {
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
        snapshot.appendItems(vm.announcements)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension AnnouncementsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
