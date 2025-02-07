//
//  Task.swift
//  SwiftUIFastAPI
//  
//  Created by SATTSAT on 2025/02/06
//  
//

import Foundation

typealias TasksResponse = [TaskResponse]

struct TaskResponse: Decodable {
    let title: String
    let id: Int
    var done: Bool
}
