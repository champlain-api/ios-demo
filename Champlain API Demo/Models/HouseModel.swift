//
// HouseModel.swift
// Champlain API Demo
//
//

import Foundation

struct HouseModel: Hashable, Codable {
    let name: String
    let students: Int
    let type: String
    let imageURL: String
    let address: String
    let distance: String

    init(
        name: String = "",
        students: Int = 0,
        type: String = "",
        imageURL: String = "",
        address: String = "",
        distance: String = ""
    ) {
        self.name = name
        self.students = students
        self.type = type
        self.imageURL = imageURL
        self.address = address
        self.distance = distance
    }
}

class HouseViewModel {
    enum FetchError: Error {
        case badRequest
    }


    struct HouseCollection: Hashable {
        let category: String
        let houses: [HouseModel]
    }

    var collection: [HouseCollection] = []

    var lastUpdated: Date = .distantPast

    func fetchData() async throws {
        let apiRequest = APIRequest()
        let (data, _) = try await apiRequest.makeRequest(endpoint: "/housing")

        do {
            let allHouses = try JSONDecoder().decode([HouseModel].self, from: data)
            self.lastUpdated = Date.now
            self.collection = self.createHouseCollections(from: allHouses).sorted {$0.category < $1.category}

        } catch {
            print(error)
        }
    }

    func createHouseCollections(from houses: [HouseModel]) -> [HouseCollection] {
        let groupedHouses = Dictionary(grouping: houses) { $0.type }

        let houseCollections = groupedHouses.map { type, houses in
            HouseCollection(category: type, houses: houses)
        }

        return houseCollections
    }
}
