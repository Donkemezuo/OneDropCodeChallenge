//
//  ApiKeys.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/21/21.
//

import Foundation

class ApiSecretKeys {
    static var timeStampString: String {
        return Date().timeIntervalSince1970.description
    }
    static var apiKey: String {
        return "6ed761906c19aaf74fff8a9cbdf880b9"
    }
    static var privateAPIKey: String {
        return "6d5c7d48cd8a9f44e88805da2fe70004e7637636"
    }
    /// According to the Marvel API Documentation, we have to pass in  an hash string of (timestamp + privateKey + publicKey)
    static func apiCredentialsHash(_ timestamp : String) -> String {
        let fullCombination = "\(timestamp)\(ApiSecretKeys.privateAPIKey)\(ApiSecretKeys.apiKey)"
        return fullCombination.hashMD5
    }
}
