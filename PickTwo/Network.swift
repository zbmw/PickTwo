//
//  Network.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import Foundation
import SwiftUI

class Network: ObservableObject {
    @Published var polls: Poll?
    @Published var teams: [Team] = []
    var rankedTeams: [Team] {
        let teams = self.teams.filter({$0.rank != nil}).sorted(by: {$0.rank ?? 99 < $1.rank ?? 98})
        return teams
    }

    func getRankings() {
        guard let url = URL(string: "https://api.collegefootballdata.com/rankings?year=2021&week=1&seasonType=postseason") else { fatalError("Missing URL") }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("YOUR API KEY HERE", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedPollList = try JSONDecoder().decode([Polls].self, from: data)
                        let decodedAPPoll = decodedPollList.first
                        self.polls = decodedAPPoll?.polls.first(where: {$0.name == "AP Top 25"})
                        print(self.polls.debugDescription)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print(response.statusCode)
            }
        }

        dataTask.resume()
    }
    
    func getTeams() {
        guard let url = URL(string: "https://api.collegefootballdata.com/teams/fbs?year=2022") else { fatalError("Missing URL") }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("YOUR API KEY HERE", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedPollList = try JSONDecoder().decode([Team].self, from: data)
                        self.teams = decodedPollList
                        self.mapRankings()
                        print(self.teams.debugDescription)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print(response.statusCode)
            }
        }

        dataTask.resume()
    }
    
    func mapRankings() {
        guard let polls = self.polls else {
            return
        }
        for team in polls.teams {
            self.teams.first(where: {$0.school == team.school})?.rank = team.rank
            print("Assigned \(team.school) a ranking of \(team.rank)")
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
