//
//  TestAPIClient.swift
//  SwiftUIFastAPI
//
//  Created by SATTSAT on 2025/02/06
//
//

import Foundation

struct TestAPIClient {
    
//    private let baseURL = URL(string: "http://localhost:8000")!
    private let baseURL: URL

    init() {
        let ipAddress = ProcessInfo.processInfo.environment["IP_ADDRESS"] ?? "localhost"
        self.baseURL = URL(string: "http://\(ipAddress):8000")!
    }

    
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
    
    func updateTaskDoneState(taskId: Int, isDone: Bool) async -> Result<Void, TestAPIClientError> {
        let url = baseURL.appending(path: "/tasks/\(taskId)/done")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = isDone ? "PUT" : "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.parseError)
            }
            return .success(())
        } catch {
            return .failure(.urlSessionError(.unknown(error)))
        }
    }
    
    func deleteTask(taskId: Int) async -> Result<Void, TestAPIClientError> {
        let url = baseURL.appending(path: "/tasks/\(taskId)/")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.parseError)
            }
            return .success(())
        } catch {
            return .failure(.urlSessionError(.unknown(error)))
        }
    }
    
    func createTask(request: TaskRequest) async -> Result<TaskCreateResponse, TestAPIClientError> {
        let url = baseURL.appending(path: "/tasks")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["title": request.title]
        do {
            urlRequest.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            print("[ERROR] エンコードに失敗")
            return .failure(.parseError)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("[ERROR] 1")
                return .failure(.parseError)
            }
            do {
                let taskCreateResponse = try JSONDecoder().decode(TaskCreateResponse.self, from: data)
                return .success(taskCreateResponse)
            } catch {
                return .failure(.parseError)
            }
        } catch {
            return .failure(.urlSessionError(.unknown(error)))
        }
    }
}
