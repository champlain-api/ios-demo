//
// ShuttleModel.swift
// Champlain API Demo
//
//

import CoreLocation
import Foundation
import MapKit

struct Shuttle: Decodable {
    var id: Int
    var updated: String
    var lat: Double
    var lon: Double
    var mph: Int
    var direction: Int
}

class ShuttleViewModel: NSObject {
    enum FetchError: Error {
        case badRequest
    }

    static var shared = ShuttleViewModel()

    var shuttles: [Shuttle] = .init()
    var lastUpdated: Date = .distantPast

    // adapted from https://developer.apple.com/tutorials/sample-apps/memecreator#Fetching-Panda-Data
    func fetchData() async throws {
        let apiRequest = APIRequest()
        let (data, _) = try await apiRequest.makeRequest(endpoint: "/shuttles")

        do {
            self.shuttles = try JSONDecoder().decode([Shuttle].self, from: data)
            self.lastUpdated = Date.now
        } catch {
            print(error)
        }
    }
}

class ShuttleAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 44.4788, longitude: -73.1950)
    var shuttleID: Int
    var title: String? = "Annotation title"
    var direction: Int = 0
    @objc dynamic var subtitle: String?

    init(
        coordinate: CLLocationCoordinate2D,
        shuttleID: Int,
        title: String? = nil,
        direction: Int = 0
    ) {
        self.coordinate = coordinate
        self.shuttleID = shuttleID
        self.title = title
        self.direction = direction
        super.init()
    }

    func returnGlyphImageForDirection() -> UIImage {
        let quadrantDirection = (((self.direction + 45) % 360) / 90)
        switch quadrantDirection {
        case 0:
            return UIImage(systemName: "arrow.up")!
        case 1:
            return UIImage(systemName: "arrow.right")!
        case 2:
            return UIImage(systemName: "arrow.down")!
        case 3:
            return UIImage(systemName: "arrow.left")!
        default:
            return UIImage(systemName: "bus.fill")!
        }
    }

}
