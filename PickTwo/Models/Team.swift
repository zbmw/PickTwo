//
//  Team.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import Foundation

class Team: Decodable {
    
    var id: Int
    var school: String
    var mascot: String
    var abbreviation: String
    var conference: String
    var logos: [String]?
    var rank: Int?
    var currentPick: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case school
        case mascot
        case abbreviation
        case conference
        case logos
        case rank
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        school = try container.decodeIfPresent(String.self, forKey: .school) ?? "N/A"
        mascot = try container.decodeIfPresent(String.self, forKey: .mascot) ?? "N/A"
        abbreviation = try container.decodeIfPresent(String.self, forKey: .abbreviation) ?? "N/A"
        conference = try container.decodeIfPresent(String.self, forKey: .conference) ?? "N/A"
        logos = try container.decodeIfPresent([String].self, forKey: .logos)
        rank = try container.decodeIfPresent(Int?.self, forKey: .rank) ?? nil
    }
    
    
}
