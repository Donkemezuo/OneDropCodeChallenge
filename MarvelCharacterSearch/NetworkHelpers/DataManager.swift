//
//  DataManager.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import Foundation
import CoreData
import UIKit

final class DataManager {
    var viewContext: NSManagedObjectContext {
        return coreDataStack.container.viewContext
    }
    private let marvelSearchApiClient = MarvelCharacterSearchApiClient()
    private var currentCharacterFetchOffset = 0
    var totalNumberOfMarvelCharacters = 0
    var numberOfCharactersFetched = 0
    
    private var currentCharacterSeriesFetchOffset = 0
    var totalSeriesForCharacter = 0
    var numberOfCharacterSeriesFetched = 0
    private let fetchLimit = 20
    
    /// - TAG: A method to fetch marvel characters from remote
    /// - parameter fetchNextBatch: A boolean value to check if we should fetch the next page
    func fetchCharactersFromApi(_ fetchNextBatch: Bool = false, completionHandler: @escaping(AppErrors?) -> ()) {
        if fetchNextBatch {
            currentCharacterFetchOffset += fetchLimit
        }
        marvelSearchApiClient.fetchCharacters(.fetchAllCharacters(offset: currentCharacterFetchOffset)) { (error, dataModel) in
            if let error = error {
                completionHandler(error)
            } else if let dataModel = dataModel {
                self.totalNumberOfMarvelCharacters = dataModel.totalCharactersCount
                self.numberOfCharactersFetched += dataModel.marvelCharacters.count
                self.syncFetchedMarvelCharactersIntoCoreData(dataModel.marvelCharacters, completionHandler: completionHandler)
            }
        }
    }
    
    /// - TAG: A method to fetch a searched marvel character from remote
    /// - parameter searchedText: User searched character name
    func fetchSearchedCharacterFromApi(_ searchedText: String, completionHandler: @escaping(AppErrors?) -> ()) {
        marvelSearchApiClient.fetchCharacters(.fetchSearchedCharacter(offset: currentCharacterFetchOffset, searchText: searchedText)) { (error, dataModel) in
            if let error = error {
                completionHandler(error)
            } else if let dataModel = dataModel {
                self.totalNumberOfMarvelCharacters = dataModel.totalCharactersCount
                self.numberOfCharactersFetched += dataModel.fetchedCharactersCount
                self.syncFetchedMarvelCharactersIntoCoreData(dataModel.marvelCharacters, completionHandler: completionHandler)
            }
        }
    }
    
    /// - TAG: A method to query remote api for all the series attributed to the passed in characterID
    /// - parameter characterID: character to search series by
    /// - parameter fetchNextBatch: A boolean value to check if we should fetch the next page
    func fetchSeriesByCharacterFromApi(_ fetchNextBatch: Bool = false, _ characterID: Int, completionHandler: @escaping(AppErrors?) -> ()) {
        if fetchNextBatch {
            currentCharacterSeriesFetchOffset += fetchLimit
        }
        marvelSearchApiClient.fetchSeriesByCharacterID(characterID, currentCharacterSeriesFetchOffset) { (error, seriesData) in
            if let error = error {
                completionHandler(error)
            } else if let dataModel = seriesData {

                self.totalSeriesForCharacter = dataModel.total
                self.numberOfCharacterSeriesFetched += dataModel.count
                self.syncSeriesByCharacterFetchedFromApiIntoCoreData(dataModel.data.results, characterID, completionHandler: completionHandler)
            }
        }
    }
    
    /// - TAG: A method that synchorizes all marvel characters fetched from remote api into coreData
    private func syncFetchedMarvelCharactersIntoCoreData(_ fetchedMarvelCharacters: [CodableMarvelCharacter], completionHandler: @escaping(AppErrors?) -> ()) {
        viewContext.performAndWait {
            self.clearExistingLocalRecordForRemoteData(.charactersData(data: fetchedMarvelCharacters)) { (error) in
                if let error = error {
                    completionHandler(error)
                } else {
                    for marvelCharacter in fetchedMarvelCharacters {
                        guard let newMarvelCharacterToSync = NSEntityDescription.insertNewObject(forEntityName: MarvelCharacter.entityName, into: self.viewContext) as? MarvelCharacter else
                        {
                            continue
                        }
                        newMarvelCharacterToSync.id = marvelCharacter.idInt64
                        newMarvelCharacterToSync.name = marvelCharacter.name
                        newMarvelCharacterToSync.thumbnailString = marvelCharacter.thumbnail.thumbnailFullPath
                        newMarvelCharacterToSync.about = marvelCharacter.description
                    }
                    if self.viewContext.hasChanges {
                        do {
                            try self.viewContext.save()
                        } catch {
                            completionHandler(.synchronizationError(error.localizedDescription))
                        }
                        self.viewContext.reset()
                    }
                }
            }
        }
    }
    /// - TAG: A method that synchorizes all series by a character fetched from remote api into coreData
    private func syncSeriesByCharacterFetchedFromApiIntoCoreData(_ series: [CodableCharacterSeries], _ charactedID: Int, completionHandler: @escaping(AppErrors?) -> ()) {
        viewContext.performAndWait {
            self.clearExistingLocalRecordForRemoteData(.seriesData(data: series)) { (error) in
                if let error = error {
                    completionHandler(error)
                } else {
                    for series in series {
                        guard let seriesToSync = NSEntityDescription.insertNewObject(forEntityName: CharacterSeries.entityName, into: self.viewContext) as? CharacterSeries else
                        {
                            continue
                        }
                        seriesToSync.seriesID = series.idToInt64
                        seriesToSync.characterID = Int64(charactedID)
                        seriesToSync.title = series.title
                        seriesToSync.thumbnailString = series.thumbnailImageString
                        seriesToSync.endYear = series.endYearString
                        seriesToSync.startYear = series.startYearString
                    }
                    if self.viewContext.hasChanges {
                        do {
                            try self.viewContext.save()
                        } catch {
                            completionHandler(.synchronizationError(error.localizedDescription))
                        }
                        self.viewContext.reset()
                    }
                }
            }
        }
    }
    
    /// - TAG: A method to clear new remote data that is already stored in Core data
    func clearExistingLocalRecordForRemoteData(_ clearingData: ClearExistingData, completionHandler: @escaping(AppErrors?) -> ()) {
        let entityName = clearingData.entityName
        var deletingIDs = [Int]()
        var predicate: NSPredicate? = nil
        switch clearingData {
        case .charactersData(data: let data):
            deletingIDs = data.map{$0.id}
            predicate = NSPredicate(format: "id IN %@", deletingIDs)
        case .seriesData(data: let data):
            deletingIDs = data.map{$0.id}
            predicate = NSPredicate(format: "seriesID IN %@", deletingIDs)
        }
        
        let deletingRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        deletingRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: deletingRequest)
        do {
            let batchDelete = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            guard let objectIDs = batchDelete?.result as? [NSManagedObjectID] else
            {
                completionHandler(nil)
                return;
            }
            let deletedObjects: [AnyHashable: Any] = [
                NSDeletedObjectsKey: objectIDs
            ]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [coreDataStack.container.viewContext])
            completionHandler(nil)
        } catch {
            completionHandler(.synchronizationError(error.localizedDescription))
        }
    }
}

enum ClearExistingData {
    case seriesData(data: [CodableCharacterSeries])
    case charactersData(data: [CodableMarvelCharacter])
    var entityName: String {
        switch self {
        case .charactersData(data: _):
            return MarvelCharacter.entityName
        case .seriesData(data: _):
            return CharacterSeries.entityName
        }
    }
}
