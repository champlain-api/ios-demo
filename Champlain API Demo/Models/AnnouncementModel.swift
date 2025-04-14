//
// AnnouncementModel.swift
// Champlain API Demo
//
//

import Foundation

struct Announcement: Decodable, Hashable {
    var id: Int
    var title: String
    var description: String 
    var style: AnnouncementStyle
    var type: [AnnouncementType]

    enum AnnouncementStyle: String, Decodable {
        case INFO
        case EMERGENCY
    }

    enum AnnouncementType: String, Decodable {
        case WEB
        case SHUTTLE
        case MOBILE
    }
}


// adapted from https://developer.apple.com/tutorials/sample-apps/memecreator#Fetching-Panda-Data
class AnnouncementViewModel: NSObject {

    static var shared = AnnouncementViewModel()
    enum FetchError: Error {
        case badRequest
    }

    var announcements: [Announcement] = []

    func fetchData(types: [Announcement.AnnouncementType] = [.MOBILE, .WEB]) async throws {
        let apiRequest = APIRequest()

        var params = URLComponents()
        params.queryItems = types.map { URLQueryItem(name: "type[]", value: $0.rawValue)}

        let (data, response) = try await apiRequest.makeRequest(endpoint: "/announcements\(params)")

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        announcements = try JSONDecoder().decode([Announcement].self, from: data)
    }
}
