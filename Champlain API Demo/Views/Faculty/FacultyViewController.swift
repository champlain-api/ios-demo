//
// HousingViewController.swift
// Champlain API Demo
//
//
// some code adapted from https://developer.apple.com/documentation/uikit/implementing-modern-collection-views
// and Copyright © 2024 Apple Inc.

import UIKit
import Kingfisher

class FacultyViewController: UIViewController {

    let vm = FacultyViewModel()
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource
    <FacultyViewModel.FacultyCollection, Faculty>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot
    <FacultyViewModel.FacultyCollection, Faculty>! = nil
    static let titleElementKind = "title-element-kind"


    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Faculty"
        tabBarItem = UITabBarItem(title: "Faculty", image: UIImage(systemName: "house.fill"), tag: 4)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                if vm.collection.count == 0 {
                    var empty = UIContentUnavailableConfiguration.empty()
                    empty.text = "No Faculty Found"
                    empty.secondaryText = "No faculty were found."
                    empty.image = UIImage(systemName: "slash.circle")

                    self.contentUnavailableConfiguration = empty
                    return
                }
            }
        }
    }
}

extension FacultyViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // if we have the space, adapt and go 2-up + peeking 3rd item
            let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
                                               0.425 : 0.85)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                                   heightDimension: .absolute(250))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: HousingViewController.titleElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

extension FacultyViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func configureDataSource() {

        let cellRegistration = UICollectionView.CellRegistration
        <FacultyCell, Faculty> { (cell, indexPath, house) in
            // Populate the cell with our item description.
            cell.titleLabel.text = house.name
            cell.categoryLabel.text = "\(house.title)"
            if house.imageURL != "", let url = URL(string: house.imageURL) {
                let processor = DownsamplingImageProcessor(size: cell.imageView.bounds.size)
                cell.imageView.kf.setImage(with: url, options: [
                    .cacheMemoryOnly,
                    .loadDiskFileSynchronously,
                    .processor(processor)
                ])
            }
        }

        dataSource = UICollectionViewDiffableDataSource
        <FacultyViewModel.FacultyCollection, Faculty>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, house: Faculty) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: house)
        }

        let supplementaryRegistration = UICollectionView.SupplementaryRegistration
        <FacultyTitleSupplementaryView>(elementKind: HousingViewController.titleElementKind) {
            (supplementaryView, string, indexPath) in
            if let snapshot = self.currentSnapshot {
                // Populate the view with our section's description.
                let houseCategory = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = houseCategory.category
            }
        }

        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }

        currentSnapshot = NSDiffableDataSourceSnapshot
        <FacultyViewModel.FacultyCollection, Faculty>()
        vm.collection.forEach {
            let collection = $0
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.faculty)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
