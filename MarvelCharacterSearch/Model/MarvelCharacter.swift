//
//  MarvelCharacter.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/22/21.
//

import Foundation
import CoreData

extension MarvelCharacter {
    var imagethumbnail: String {
        return thumbnailString ?? ""
    }
    var characterName: String {
        return name ?? ""
    }
    var characterDescription: String {
        return about ?? ""
    }
    var characterID: Int {
        return Int(id)
    }
    static var entityName: String {
        return "MarvelCharacter"
    }
}
