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
    var timer = Timer()
    var didCreateInitialMarkers = false

    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Shuttle", image: UIImage(systemName: "bus.fill"), tag: 1)
        mapView.delegate = self
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
                empty.secondaryText = "There were no shuttles found. Please try again later."
                empty.image = UIImage(systemName: "slash.circle")
                
//                var retryButton = UIButton.Configuration.borderless()
//                retryButton.title = "Refresh"
//                empty.button = retryButton
//                empty.buttonProperties.primaryAction = UIAction(handler: { handler in
//                    print("clicked")
//                })
                
                self.contentUnavailableConfiguration = empty
                
                return
            }
            self.contentUnavailableConfiguration = nil
            
            // some code from https://stackoverflow.com/a/73032295
            
            for shuttleAnnotation in vm.annotations {
                UIView.animate(withDuration: 0.5) { [self] in
                    if let shuttle = vm.shuttles.first(where: { $0.id == shuttleAnnotation.shuttleID }) {
                        shuttleAnnotation.coordinate = CLLocationCoordinate2D(
                            latitude: CLLocationDegrees(shuttle.lat),
                            longitude: CLLocationDegrees(shuttle.lon)
                        )
                        shuttleAnnotation.direction = shuttle.direction
                    }
                }
            }
            
            if vm.shuttles.count == vm.annotations.count {return}
            
            for shuttle in vm.shuttles {
                let shuttleAnnotation = ShuttleAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: shuttle.lat, longitude: shuttle.lon),
                    shuttleID: shuttle.id,
                    direction: shuttle.direction
                )
                shuttleAnnotation.title = "Shuttle \(shuttle.id)"
                vm.annotations.append(shuttleAnnotation)
            }
            
            mapView.addAnnotations(vm.annotations)
            
            didCreateInitialMarkers = true
            
            mapView.isHidden = false
            self.contentUnavailableConfiguration = nil
        }
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation, annotation.isKind(of: ShuttleAnnotation.self) {
            // TODO: add a sheet here
            print("annotation tapped")
        }
    }

}

private func setupShuttleAnnotation(for annotation: ShuttleAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    let identifier = NSStringFromClass(ShuttleAnnotation.self)
    let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
    if let markerAnnotationView = view as? MKMarkerAnnotationView {
        markerAnnotationView.animatesWhenAdded = true
        markerAnnotationView.canShowCallout = true

        // TODO: find a way for this to update on each update
        markerAnnotationView.glyphText = "\(annotation.direction)"
//        markerAnnotationView.glyphImage = {
//            if annotation.direction > 0 && annotation.direction <= 90 {
//                return UIImage(systemName: "arrow.up")
//            } else if annotation.direction > 90 && annotation.direction <= 180 {
//                return UIImage(systemName: "arrow.right")
//            } else if annotation.direction > 180 && annotation.direction <= 270 {
//                return UIImage(systemName: "arrow.down")
//            } else if annotation.direction > 271 && annotation.direction <= 360 {
//                return UIImage(systemName: "arrow.left")
//            }
//            else {
//                return UIImage(systemName: "bus.fill")
//            }
//        }()
        markerAnnotationView.markerTintColor = UIColor.black
        let rightButton = UIButton(type: .detailDisclosure)
        markerAnnotationView.rightCalloutAccessoryView = rightButton
    }
    return view
}
