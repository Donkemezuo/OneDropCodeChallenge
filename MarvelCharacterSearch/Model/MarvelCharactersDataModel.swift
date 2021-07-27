//
//  MarvelCharactersDataModel.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import Foundation

struct MarvelCharactersDataModel: Codable {
    let data: MarvelCharacterCodableDataWrapper
    var marvelCharacters: [CodableMarvelCharacter] {
        return data.results
    }
    var totalCharactersCount: Int {
        return data.total
    }
    var fetchedCharactersCount: Int {
        return marvelCharacters.count
    }
}

struct MarvelCharacterCodableDataWrapper: Codable {
    let offset: Int
    let total: Int
    let results: [CodableMarvelCharacter]
}

struct CodableMarvelCharacter: Codable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: CodableMarvelCharacterThumbnailWrapper
    var idInt64: Int64 {
        return Int64(id)
    }
}

struct CodableMarvelCharacterThumbnailWrapper: Codable {
    let path: String
    let pathExtension: String
    var thumbnailFullPath: String {
        let fullPath_with_http = path + "." + pathExtension
        var components = URLComponents(string: fullPath_with_http)!
        components.scheme = "https"
        let fullPath_with_https = components.string ?? ""
        return fullPath_with_https
    }
    enum CodingKeys: String, CodingKey {
        case pathExtension = "extension"
        case path
    }
}
