//
//  AppErrors.swift
//  MarvelCharacterSearch

//
//  Created by Raymond Donkemezuo on 7/21/21.
//

import Foundation

enum AppErrors {
    case invalidURL(String)
    case networkError(String)
    case badStatusCode(String)
    case jsonDecodingError(String)
    case synchronizationError(String)
    
    var errorMessage: (devError: String, userError: String) {
        var devError = ""
        let userError = "Unexpected error encountered. Please try again"
        switch self {
        case .invalidURL(let urlString):
            devError = "url \(urlString) is invalid"
            return (devError, userError)
        case .networkError(let errorMessage):
            devError = "Unexpected network error: \(errorMessage) encountered"
            return (devError, userError)
        case .badStatusCode(let message):
            devError = "Bad status code: \(message)"
            return (devError, userError)
        case .jsonDecodingError(let decodingErrorMessage):
            devError = "Error \(decodingErrorMessage) encountered when decoding"
            return (devError, userError)
        case .synchronizationError(let syncErrorMessage):
            devError = "Error - \(syncErrorMessage) encountered while synchronizingData"
            return (devError, userError)
        }
    }
}
