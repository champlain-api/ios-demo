//
// ShuttleViewController.swift
// Champlain API Demo
//
//

import MapKit
import UIKit
import SnapKit


class ShuttleViewController: UIViewController {
    let mapView = MKMapView()
    let vm = ShuttleViewModel.shared
    let announcementsVM = AnnouncementViewModel()
    var timer = Timer()

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Shuttle Tracker", image: UIImage(systemName: "bus.fill"), tag: 1)
        mapView.delegate = self

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
        self.navigationItem.title = "Shuttle Map"
        view.addSubview(mapView)
        mapView.isHidden = true
        
        var empty = UIContentUnavailableConfiguration.loading()
        empty.text = "Loading Shuttle Data"
        self.contentUnavailableConfiguration = empty
        
        mapView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .muted)
        mapView.cameraBoundary = MKMapView.CameraBoundary(
            coordinateRegion: .init(
                center: CLLocationCoordinate2D(latitude: 44.46982, longitude: -73.21009),
                latitudinalMeters: 3000,
                longitudinalMeters: 3000
            )
        )
        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 800, maxCenterCoordinateDistance: 8000), animated: true)
        
        self.mapView.setRegion(
            .init(
                center: CLLocationCoordinate2D(latitude: 44.46982, longitude: -73.21009),
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ),
            animated: true
        )

        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(ShuttleAnnotation.self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            try? await announcementsVM.fetchData(types: [.SHUTTLE])
            self.tabBarItem.badgeValue = String(announcementsVM.announcements.count)

        }
        fetchShuttles()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fetchShuttles), userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    @objc func fetchShuttles() {
        Task {
            try await vm.fetchData()
            if vm.shuttles.count == 0 {
                mapView.isHidden = true
                var empty = UIContentUnavailableConfiguration.empty()
                empty.text = "No Shuttles Found"
                empty.secondaryText = "No shuttles have currently been updated within the past 2 hours. Please try again later."
                empty.image = UIImage(systemName: "slash.circle")

                self.contentUnavailableConfiguration = empty
                return
            }
            self.contentUnavailableConfiguration = nil

            // Check if the number of shuttles that the API responds with
            // is different than the number of annotations we have on our map
            if mapView.annotations.count != vm.shuttles.count {
                mapView.removeAnnotations(mapView.annotations)

                for shuttle in vm.shuttles {
                    let shuttleAnnotation = ShuttleAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: shuttle.lat, longitude: shuttle.lon),
                        shuttleID: shuttle.id,
                        direction: shuttle.direction
                    )
                    shuttleAnnotation.title = "Shuttle \(shuttle.id)"
                    shuttleAnnotation.subtitle = "MPH: \(shuttle.mph)"
                    mapView.addAnnotation(shuttleAnnotation)
                }
            }

            for mapAnnotation in mapView.annotations {
                UIView.animate(withDuration: 0.5) { [self] in
                    if let shuttleAnnotation = mapAnnotation as? ShuttleAnnotation,let shuttle = vm.shuttles.first(
                        where: {$0.id == shuttleAnnotation.shuttleID }) {
                        shuttleAnnotation.coordinate = CLLocationCoordinate2D(
                            latitude: shuttle.lat,
                            longitude: shuttle.lon
                        )
                        shuttleAnnotation.direction = shuttle.direction
                        shuttleAnnotation.subtitle = "MPH: \(shuttle.mph)"
                        if let markerView = mapView.view( for: shuttleAnnotation) as? MKMarkerAnnotationView {
                            markerView.glyphImage = shuttleAnnotation.returnGlyphImageForDirection()
                        }
                    }
                }
            }

            mapView.isHidden = false
            self.contentUnavailableConfiguration = nil
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

extension ShuttleViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {return nil}
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? ShuttleAnnotation {
            annotationView = setupShuttleAnnotation(for: annotation, on: mapView)
        }
        return annotationView
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if let annotation = view.annotation, annotation.isKind(of: ShuttleAnnotation.self) {
//            // TODO: add a sheet here
//            print("annotation tapped")
//        }
//    }

}

private func setupShuttleAnnotation(for annotation: ShuttleAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    let identifier = NSStringFromClass(ShuttleAnnotation.self)
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
    if let markerAnnotationView = view as? MKMarkerAnnotationView {
        markerAnnotationView.animatesWhenAdded = true
        markerAnnotationView.canShowCallout = true

        markerAnnotationView.glyphImage = annotation.returnGlyphImageForDirection()

        markerAnnotationView.markerTintColor = UIColor.label
        let rightButton = UIButton(type: .detailDisclosure)
        markerAnnotationView.rightCalloutAccessoryView = rightButton
    }
    return view
}


