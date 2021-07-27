//
//  String+Extensions.swift
//  MarvelCharacterSearch
//
//  Created by Raymond Donkemezuo on 7/21/21.
//

import Foundation
import CryptoKit

extension String {
    var hashMD5: String {
        guard let stringData = self.data(using: .utf8) else
        {
            return ""
        }
        let digest = Insecure.MD5.hash(data: stringData)
        return digest.map{String(format: "%02hhx", $0)}.joined()
    }
}
