//
// TabBarViewController.swift
// Champlain API Demo
//
//

import UIKit

class TabBarViewController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        let shuttleViewController = UINavigationController(rootViewController: ShuttleViewController())
        let houseViewController = UINavigationController(rootViewController: HousingViewController())
        let buildingViewController = UINavigationController(rootViewController: BuildingViewController())
        let facultyViewController = UINavigationController(rootViewController: FacultyViewController())

        
        setViewControllers([homeViewController, shuttleViewController, houseViewController, buildingViewController, facultyViewController], animated: false)

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
