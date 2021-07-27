//
//  CharacterSeries.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/25/21.
//

import Foundation
import CoreData

extension CharacterSeries {
    var imageString: String {
        return thumbnailString ?? ""
    }
    
    var startYearString: String {
        return startYear ?? ""
    }
    
    var endYearString: String {
        return endYear ?? ""
    }
    
    static var entityName: String {
        return "CharacterSeries"
    }
}
