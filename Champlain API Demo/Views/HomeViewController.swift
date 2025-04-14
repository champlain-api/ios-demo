//
// HomeViewController.swift
// Champlain API Demo
//
//

import UIKit

class HomeViewController: UIViewController {
    let announcementsVM = AnnouncementViewModel.shared
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Info", image: UIImage(systemName: "info.square.fill"), tag: 0)

        let announcementsButton = UIBarButtonItem(
            image: UIImage(systemName: "bell.fill"),
            style: .plain,
            target: self,
            action: #selector(openAnnouncementsVC)
        )

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            try? await announcementsVM.fetchData()
            self.tabBarItem.badgeValue = String(announcementsVM.announcements.count)

        }
    }

    @objc func openAnnouncementsVC() {
        let vc = AnnouncementsView(viewModel: announcementsVM)
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
