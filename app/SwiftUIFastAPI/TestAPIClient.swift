//
//  TestAPIClient.swift
//  SwiftUIFastAPI
//
//  Created by SATTSAT on 2025/02/06
//
//

import Foundation

struct TestAPIClient {
    
    private let baseURL = URL(string: "http://localhost:8000")!
    //自分のipアドレスにすることで、問題解決
    
    
    func fetchTasks() async -> Result<TasksResponse, TestAPIClientError> {
        
        // エンドポイントを指定
        let urlComponents = URLComponents(
            url: baseURL.appending(path: "/tasks"),
            resolvingAgainstBaseURL: true
        )
        
        // URLが有効かチェック
        guard let url = urlComponents?.url else {
            return .failure(.invalidURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpURLResponse = response as? HTTPURLResponse else {
                preconditionFailure()
            }
            
            switch httpURLResponse.statusCode {
            case 200:
                do {
                    let tasksResponse = try JSONDecoder().decode(TasksResponse.self, from: data)
                    return .success(tasksResponse)
                } catch {
                    return .failure(.parseError)
                }
            case 400:
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    return .failure(.apiResponseError(.badRequest(response: errorResponse)))
                } catch {
                    return .failure(.parseError)
                }
            default:
                return .failure(.apiResponseError(.undefined(statusCode: httpURLResponse.statusCode)))
            }
        } catch {
            return .failure(.urlSessionError(.unknown(error)))
        }
    }
}
