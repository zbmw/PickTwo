//
//  Network.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import Foundation
import SwiftUI
import Firebase

class Network: ObservableObject {
    @Published var polls: Poll?
    @Published var teams: [Team] = []
    @Published var user: UserProfile? 
    
    var rankedTeams: [Team] {
        let teams = self.teams.filter({$0.rank != nil}).sorted(by: {$0.rank ?? 99 < $1.rank ?? 98})
        return teams
    }

    func getRankings() {
        guard let url = URL(string: "https://api.collegefootballdata.com/rankings?year=2022&week=1&seasonType=regular") else { fatalError("Missing URL") }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(Constants.accessToken, forHTTPHeaderField: "Authorization")

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
    
    func getUser(id: String) -> UserProfile? {
        let db = Firestore.firestore()
        var ref: DocumentReference
        if !id.isEmpty {
            ref = db.collection("users").document(id)
        } else {
            return nil
        }
        
        ref.getDocument { document, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "")")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                
                let uid = data?["uid"] as? String ?? ""
                let currentPicks = data?["currentPicks"] as? [String] ?? []
                let name = data?["name"] as? String ?? ""
                let previousPicks = data?["previousPicks"] as? [String] ?? []
                if uid == id {
                    if self.user == nil {
                        self.user = UserProfile()
                    }
                    self.user?.id = uid
                    self.user?.currentPicks = currentPicks
                    self.user?.name = name
                    self.user?.previousPicks = previousPicks
                    print("User was found")
                }
            } else {
                print("snapshot does not exist")
            }
        }
        if user == nil {
            print("User was not found")
        }
        return user
    }
    
    func setPicks(picks: [Team], id: String, name: String, previousPicks: [String]) {
        var friendlyNames: [String]? = []
        for pick in picks {
            friendlyNames?.append(pick.school)
        }
        let db = Firestore.firestore()
        let ref = db.collection("users").document(id)
        ref.setData(["currentPicks": friendlyNames ?? [nil,nil],
                     "uid": id,
                     "name": name,
                    "previousPicks": previousPicks]) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
        }
        friendlyNames = nil
    }
    
    func setName(id: String, name: String) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(id)
        ref.setData({
            ["name": name,
             "uid": id]
        }(), merge: true)
    }

    
    func getTeams() {
        guard let url = URL(string: "https://api.collegefootballdata.com/teams/fbs?year=2022") else { fatalError("Missing URL") }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(Constants.accessToken, forHTTPHeaderField: "Authorization")

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

    
}
