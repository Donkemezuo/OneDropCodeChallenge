//
//  SeriesDataModel.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import Foundation
import CoreData

final class CharacterSeriesDataModel: Codable {
    let data: CodableSeriesDataModelWrapper
    var count: Int {
        return data.results.count
    }
    var total: Int {
        return data.total
    }
}

struct CodableSeriesDataModelWrapper: Codable {
    var results: [CodableCharacterSeries]
    var total: Int
}

struct CodableCharacterSeries: Codable {
    var id: Int
    var title: String
    var seriesDescription: String?
    var startYear: Int
    var endYear: Int
    var thumbnail: CodableSeriesThumbnailWrapper
    var thumbnailImageString: String {
        return thumbnail.thumbnailFullPath
    }
    enum CodingKeys: String, CodingKey {
        case seriesDescription = "description"
        case title
        case id
        case startYear
        case endYear
        case thumbnail
    }
    var idToInt64: Int64 {
        return Int64(id)
    }
    var endYearString: String {
        return String(endYear)
    }
    
    var startYearString: String {
        return String(startYear)
    }
}

struct CodableSeriesThumbnailWrapper: Codable {
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
