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

class AnnouncementViewModel: NSObject {

    static var shared = AnnouncementViewModel()
    enum FetchError: Error {
        case badRequest
    }

    var announcements: [Announcement] = []

    func fetchData(types: [Announcement.AnnouncementType] = [.MOBILE, .SHUTTLE]) async throws {
        let apiRequest = APIRequest()
        let (data, response) = try await apiRequest.makeRequest(endpoint: "/announcements")

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }

        announcements = try JSONDecoder().decode([Announcement].self, from: data)
    }
}
