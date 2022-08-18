//
//  Poll.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import Foundation

struct Polls: Decodable {
    let season: Int
    let seasonType: String
    let week: Int
    let polls: [Poll]
    
    enum CodingKeys: String, CodingKey {
        case season
        case seasonType
        case week
        case polls
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        season = try container.decode(Int.self, forKey: .season)
        seasonType = try container.decode(String.self, forKey: .seasonType)
        week = try container.decode(Int.self, forKey: .week)
        polls = try container.decode([Poll].self, forKey: .polls)
    }
}

struct Poll: Decodable {
    let name: String
    let teams: [RankedTeam]
    
    enum CodingKeys: String, CodingKey {
        case name = "poll"
        case teams = "ranks"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self ,forKey: .name)
        teams = try container.decode([RankedTeam].self, forKey: .teams)
    }
    
}

struct RankedTeam: Decodable {
    var rank: Int
    let school: String
    let conference: String?
    
    enum CodingKeys: String, CodingKey {
        case rank
        case school
        case conference
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rank = try container.decode(Int.self ,forKey: .rank)
        school = try container.decode(String.self, forKey: .school)
        conference = try container.decodeIfPresent(String.self, forKey: .conference)
    }
}
