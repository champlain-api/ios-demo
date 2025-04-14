//
// BuildingViewController.swift
// Champlain API Demo
//
//
// some code adapted from https://developer.apple.com/documentation/uikit/implementing-modern-collection-views
// and Copyright © 2024 Apple Inc.


import UIKit

class BuildingViewController: UIViewController {

    enum Section {
        case main
    }
    let vm = BuildingViewModel.shared

    var dataSource: UICollectionViewDiffableDataSource<Section, Building>! = nil
    var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Building Information"
        Task {
            self.contentUnavailableConfiguration = nil
            try? await vm.fetchData()
            configureHierarchy()
            configureDataSource()

        }
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentUnavailableConfiguration = nil
        Task {
            try? await vm.fetchData()
            // if this hasn't been configured yet
            if let collectionView {
                configureDataSource()
                collectionView.reloadData()
                if vm.buildings.count == 0 {
                    var empty = UIContentUnavailableConfiguration.empty()
                    empty.text = "No Buildings Found"
                    empty.secondaryText = "No buildings were found."
                    empty.image = UIImage(systemName: "slash.circle")

                    self.contentUnavailableConfiguration = empty
                    return
                }
            }
        }
    }


    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Building", image: UIImage(systemName: "building.fill"), tag: 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BuildingViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension BuildingViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Building> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = "\(item.name)"
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
            content.textProperties.adjustsFontForContentSizeCategory = true
            content.secondaryText = "\(item.location) | \(item.hours[1]["hours"] ?? "Not open on Tuesdays")"
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Building>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Building) -> UICollectionViewCell? in

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Building>()
        snapshot.appendSections([.main])
        snapshot.appendItems(vm.buildings)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension BuildingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
