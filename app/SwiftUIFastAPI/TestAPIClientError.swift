//
//  APIClientError.swift
//  SwiftUIFastAPI
//  
//  Created by SATTSAT on 2025/02/06
//  
//

import Foundation

/// API通信のエラー
enum TestAPIClientError: Error {
    /// URLが無効
    case invalidURL
    /// パースに失敗
    case parseError
    /// ステータスコードエラー
    case apiResponseError(APIResponseError)
    /// URLSessionでのエラー
    case urlSessionError(URLSessionError)
}

/// ステータスコードエラー
enum APIResponseError: Error {
    /// ステータスコード: 400
    case badRequest(response: ErrorResponse)
    /// ステータスコード: 401
    case tokenError
    /// ステータスコード: 500
    case serverError
    /// 定義されていないステータスコード
    case undefined(statusCode: Int?)
}

/// URLSessionでのエラー
enum URLSessionError: Error {
    /// ネットワークエラー
    case networkError
    /// 型不明のエラー
    case unknown(Error)
}
