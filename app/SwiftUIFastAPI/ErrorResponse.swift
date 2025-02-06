//
//  ErrorResponse.swift
//  SwiftUIFastAPI
//  
//  Created by SATTSAT on 2025/02/06
//  
//

import Foundation

struct ErrorResponse: Decodable {
    let errors: [ErrorModel]
}

struct ErrorModel: Decodable {
    let detail: String
}
