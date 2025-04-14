//
// APIRequest.swift
// Champlain API Demo
//
//

import Foundation

struct APIRequest {
    enum FetchError: Error {
        case badRequest
        case invalidURL
    }

    // adapted from https://developer.apple.com/tutorials/sample-apps/memecreator#Fetching-Panda-Data
    func makeRequest(endpoint: String) async throws -> (data: Data, response: URLResponse) {

        guard let url = URL(string: "http://localhost:3000" + endpoint) else { throw FetchError.invalidURL }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 10

        let (data, response) = try await URLSession(configuration: config).data(for: URLRequest(url: url))

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        return (data, response)
    }
}
