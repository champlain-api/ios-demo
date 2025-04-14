//
// HomeViewController.swift
// Champlain API Demo
//
//

import UIKit

class HomeViewController: UIViewController {
    let announcementsStackView = UIStackView()
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let announcementsButton = UIBarButtonItem(
            image: UIImage(systemName: "bell.circle"),
            style: .plain,
            target: self,
            action: #selector(openAnnouncementsVC)
        )
        self.tabBarItem.badgeValue = "2"

        navigationItem.rightBarButtonItem = announcementsButton
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
    }

    @objc func openAnnouncementsVC() {
        let vc = AnnouncementsView()
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(dismissSheet)
        )
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true)
    }

    @objc func dismissSheet() {
        self.dismiss(animated: true)
    }
}
