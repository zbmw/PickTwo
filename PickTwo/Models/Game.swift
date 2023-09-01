//
//  Game.swift
//  PickTwo
//
//  Created by Brett Walton on 8/18/22.
//

import Foundation

class Game: Decodable {
    var homeTeam: String
    var awayTeam: String
    var homePoints: Int?
    var awayPoints: Int?
    var time: String?
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case homePoints = "home_points"
        case awayPoints = "away_points"
        case time = "start_date"
    }
    
    required init(from decoder: Decoder) throws {
        let containter = try decoder.container(keyedBy: CodingKeys.self)
        homeTeam = try containter.decodeIfPresent(String.self, forKey: .homeTeam) ?? "N/A"
        awayTeam = try containter.decodeIfPresent(String.self, forKey: .awayTeam) ?? "N/A"
        homePoints = try containter.decodeIfPresent(Int.self, forKey: .homePoints) ?? 0
        awayPoints = try containter.decodeIfPresent(Int.self, forKey: .awayPoints) ?? 0
        time = try containter.decodeIfPresent(String.self, forKey: .time) ?? ""
    }
}
