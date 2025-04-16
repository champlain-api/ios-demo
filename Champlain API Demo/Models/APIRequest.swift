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

    func makeRequest(endpoint: String) async throws -> (data: Data, response: URLResponse) {
        guard let url = URL(string: "http://containers.mahi-duck.ts.net:3000/api" + endpoint) else { throw FetchError.invalidURL }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 5

        let (data, response) = try await URLSession(configuration: config).data(for: URLRequest(url: url))
        

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        return (data, response)
    }
}
