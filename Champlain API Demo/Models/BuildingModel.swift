//
// BuildingModel.swift
// Champlain API Demo
//
//

import Foundation

struct Building: Decodable, Hashable {
    var id: Int
    var name: String
    var location: String
    var hours: [[String:String]]


}

class BuildingViewModel: NSObject {

    static var shared = BuildingViewModel()
    enum FetchError: Error {
        case badRequest
    }

    var buildings: [Building] = []

    // adapted from https://developer.apple.com/tutorials/sample-apps/memecreator#Fetching-Panda-Data
    func fetchData() async throws {
        let apiRequest = APIRequest()
        let (data, response) = try await apiRequest.makeRequest(endpoint: "/building")

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        buildings = try JSONDecoder().decode([Building].self, from: data)
    }
}
