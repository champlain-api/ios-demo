//
// HousingCell.swift
// Champlain API Demo
//
// Copyright Hayden Clark. All rights reserved.
//
//
// some code adapted from https://developer.apple.com/documentation/uikit/implementing-modern-collection-views
// and Copyright © 2024 Apple Inc.


import UIKit

class FacultyCell: UICollectionViewCell {

    static let reuseIdentifier = "faculty-cell-reuse-identifier"
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let categoryLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension FacultyCell {
    func configure() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.numberOfLines = 0
        categoryLabel.textColor = .secondaryLabel

        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = UIColor.systemCyan
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.snp.makeConstraints { make in
            make.top.left.equalTo(contentView)
            make.width.equalTo(contentView)
            make.height.equalTo(175)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(contentView)
        }
    }
}


class FacultyTitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "faculty-title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

