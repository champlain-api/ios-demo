//
// FacultyModel.swift
// Champlain API Demo
//
//

import Foundation

struct Faculty: Hashable, Codable, Identifiable {
    let name: String
    let title: String
    let imageURL: String
    let departments: [String]
    let id: Int

    init(
        name: String = "",
        title: String = "",
        imageURL: String = "",
        departments: [String] = [],
        id: Int = 0
    ) {
        self.name = name
        self.title = title
        self.imageURL = imageURL
        self.departments = departments
        self.id = id
    }
}

class FacultyViewModel {
    enum FetchError: Error {
        case badRequest
    }


    struct FacultyCollection: Hashable {
        let category: String
        let faculty: [Faculty]
    }

    var collection: [FacultyCollection] = []

    var lastUpdated: Date = .distantPast

    // adapted from https://developer.apple.com/tutorials/sample-apps/memecreator#Fetching-Panda-Data
    func fetchData() async throws {
        let apiRequest = APIRequest()
        let (data, _) = try await apiRequest.makeRequest(endpoint: "/faculty")

        do {
            let allFaculty = try JSONDecoder().decode([Faculty].self, from: data)
            self.lastUpdated = Date.now
            self.collection = self.createCollection(from: allFaculty).sorted {$0.category < $1.category}

        } catch {
            print(error)
        }
    }

    func createCollection(from faculty: [Faculty]) -> [FacultyCollection] {
        let groupFaculty = Dictionary(grouping: faculty) { $0.departments.first?.uppercased() ?? "No departments" }

        let facultyCollection = groupFaculty.map { type, faculty in
            FacultyCollection(category: type, faculty: faculty)
        }

        return facultyCollection
    }
}

