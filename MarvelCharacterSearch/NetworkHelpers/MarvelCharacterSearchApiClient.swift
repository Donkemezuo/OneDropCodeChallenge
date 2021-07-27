//
//  MarvelHeroesAPIClient.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/21/21.
//

import Foundation

enum MarvelCharacterSearchEndPoint {
    case fetchAllCharacters(offset: Int)
    case fetchSearchedCharacter(offset: Int, searchText: String)
    case fetchSeriesByCharacterID(characterID: Int, currentOffset: Int)
    
    private var baseURLCharactersFetch: String {
        return "https://gateway.marvel.com/v1/public/characters"
    }
    private var baseURLSeriesFetch: String {
        return "https://gateway.marvel.com:443/v1/public/series"
    }
    
    var endpointstring: String {
        let timestampString = ApiSecretKeys.timeStampString
        switch self {
        case .fetchAllCharacters(let offset):
            return "\(baseURLCharactersFetch)?limit=20&offset=\(offset)&ts=\(timestampString)&apikey=\(ApiSecretKeys.apiKey)&hash=\(ApiSecretKeys.apiCredentialsHash(timestampString))"
        case .fetchSearchedCharacter(let offset, let searchText):
            return "\(baseURLCharactersFetch)?name=\(searchText)&limit=20&offset=\(offset)&ts=\(timestampString)&apikey=\(ApiSecretKeys.apiKey)&hash=\(ApiSecretKeys.apiCredentialsHash(timestampString))"
        case .fetchSeriesByCharacterID(characterID: let id, let offset):
            return "\(baseURLSeriesFetch)?characters=\(id)&offset=\(offset)&ts=\(timestampString)&apikey=\(ApiSecretKeys.apiKey)&hash=\(ApiSecretKeys.apiCredentialsHash(timestampString))"
        }
    }
    
}

class MarvelCharacterSearchApiClient {
    let timestampString = ApiSecretKeys.timeStampString
    private struct Constants {
        static let badStatusCode = -999
        static let goodURLResponseStatusCodeRange = (200...299)
    }
    
    /// - TAG: A method to fetch a list of Marvel characters
    /// - parameter endPoint: returns an endpoint depending on the type of fetch
    func fetchCharacters(_ endpoint: MarvelCharacterSearchEndPoint, completionHandler: @escaping(AppErrors?, MarvelCharactersDataModel?) -> ()) {
        let endPoint = endpoint.endpointstring
        guard let endPointURL = URL(string: endPoint) else
        {
            completionHandler(.invalidURL(endPoint), nil)
            return;
        }
        let urlRequest = URLRequest(url: endPointURL)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completionHandler(.networkError(error.localizedDescription), nil)
            } else if let response = response {
                guard let httpResponse = response as? HTTPURLResponse,
                      Constants.goodURLResponseStatusCodeRange.contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? Constants.badStatusCode
                    completionHandler(.badStatusCode(String(statusCode)), nil)
                    return;
                }
                if let data = data {
                    do {
                        let decodedDataModel = try JSONDecoder().decode(MarvelCharactersDataModel.self, from: data)
                        completionHandler(nil, decodedDataModel)
                    } catch {
                        completionHandler(.jsonDecodingError(error.localizedDescription), nil)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    /// - TAG: A method to fetch the series of a marvel character
    /// - parameter characterID: The id of the career who's series we are fetching
    /// - parameter currentOffset: The current offset of our endpoint
    func fetchSeriesByCharacterID( _ characterID: Int,_ currentOffset: Int, completionHandler: @escaping(AppErrors?, CharacterSeriesDataModel?) -> ()) {
        let endPoint = MarvelCharacterSearchEndPoint.fetchSeriesByCharacterID(characterID: characterID, currentOffset: currentOffset).endpointstring
        guard let endPointURL = URL(string: endPoint) else
        {
            completionHandler(.invalidURL(endPoint), nil)
            return;
        }
        let urlRequest = URLRequest(url: endPointURL)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completionHandler(.networkError(error.localizedDescription), nil)
            } else if let response = response {
                guard let httpResponse = response as? HTTPURLResponse,
                      Constants.goodURLResponseStatusCodeRange.contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? Constants.badStatusCode
                    completionHandler(.badStatusCode(String(statusCode)), nil)
                    return;
                }
                if let data = data {
                    do {
                        let decodedDataModel = try JSONDecoder().decode(CharacterSeriesDataModel.self, from: data)
                        completionHandler(nil, decodedDataModel)
                    } catch {
                        completionHandler(.jsonDecodingError(error.localizedDescription), nil)
                    }
                }
            }
        }
        dataTask.resume()
    }
}
