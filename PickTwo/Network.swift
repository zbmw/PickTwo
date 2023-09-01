//
//  Network.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import Foundation
import SwiftUI
import Firebase

@MainActor class Network: ObservableObject {
    @Published var polls: Poll?
    @Published var teams: [Team] = []
    @Published var user: UserProfile?
    @Published var standings: [String:Int] = [:]
    @Published var matchups: [Game] = []
    @Published var rankedGames: [Game] = []
    @Published var users: [User] = []
    
    @Published var config: Config = Config(week: "", picksLock: nil) {
        didSet {
            if !config.week.isEmpty {
                Task {
                    await getRankings()
                    getMatchups()
                }
            }
        }
    }
    
    
    func clearInfo() {
        polls = nil
        teams = []
        user = nil
        standings = [:]
        matchups = []
        rankedGames = []
        users = []
        config = Config(week: "", picksLock: nil)
    }
    
    var rankedTeams: [Team] {
        let teams = self.teams.filter({$0.rank != nil}).sorted(by: {$0.rank ?? 99 < $1.rank ?? 98})
        return teams
    }
    
    var rankedTeamsStrings: [String] {
        var names: [String] = []
        for team in rankedTeams {
            names.append(team.school)
        }
        return names
    }
    
    func rankingForTeam(team: String) -> String? {
        let ranking = rankedTeams.first(where: {$0.school == team})
        guard let rank = ranking, let number = rank.rank else {
            return nil
        }
        return String(describing: number)
    }
    
    var rankedMatchups: [Game] {
        var games: [Game] = []
        let matchips = matchups
        for game in matchups {
            if rankedTeamsStrings.contains(where: {($0.self == game.homeTeam) || ($0.self == game.awayTeam)}) {
                games.append(game)
            }
        }
        return games
    }
    
    func getMatchups() {
        guard let url = URL(string: "https://api.collegefootballdata.com/games?year=2023&week=\(self.config.week)&seasonType=regular&division=fbs"), !self.config.week.isEmpty else {
            return
        }
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
                        self.matchups = try JSONDecoder().decode([Game].self, from: data)
                        print(self.matchups.debugDescription)
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
    
    func translateDate(game: Game) -> String? {
        let dateFormatter = ISO8601DateFormatter([.withInternetDateTime,.withFractionalSeconds])
        let dateString = game.time ?? ""
        let formatted = dateFormatter.date(from: dateString)?.formatted()
        return formatted
    }
    
    func translateDate(date: String) -> String? {
        let dateFormatter = ISO8601DateFormatter([.withInternetDateTime,.withFractionalSeconds])
        //let dateString = date
        let formatted = dateFormatter.date(from: date)?.formatted(date: .long, time: .complete)
        return formatted
    }
    
    func translateDate(dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter([.withInternetDateTime,.withFractionalSeconds,.withColonSeparatorInTime])
        //let dateString = date
        let formatted = dateFormatter.date(from: dateString)//?.formatted(date: .long, time: .complete)
        return formatted
    }
    
    func getRankings() async {
        guard let url = URL(string: "https://api.collegefootballdata.com/rankings?year=2023&week=\(self.config.week)&seasonType=regular"), !self.config.week.isEmpty else {
            return
        }

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
    
    func getAllUsers() -> [String:Int]? {
        let db = Firestore.firestore()
        var standings: [String:Int] = [:]
        let users = db.collection("users")
        users.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "")")
                return
            }
            for document in snapshot!.documents {
                let data = document.data()
                let name = data["name"] as? String ?? "N/A"
                let strikes = data["strikes"] as? Int ?? 0
                standings["\(name)"] = strikes
                print("Got user named -> \(name) <- with \(strikes) strikes")
                print(standings.description)
            }
            print("final: \(standings.description)")
            self.standings = standings
        }
        return self.standings
    }
    
    func getAllPicks() {
        let db = Firestore.firestore()
        let users = db.collection("users")
        users.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "")")
                return
            }
            for document in snapshot!.documents {
                let data = document.data()
                let name = data["name"] as? String ?? "N/A"
                let strikes = data["strikes"] as? Int ?? 0
                let currentPicks = data["currentPicks"] as? [String] ?? []
                print("Got user named -> \(name) <- with \(currentPicks.description) picks")
                let user = User(name: name, strikes: strikes, currentPicks: currentPicks)
                if !(self.users.contains(where: {$0.name == user.name})) {
                    self.users.append(user)
                }
            }
        }
        
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
    
    func getConfig() async {
        let db = Firestore.firestore()
        let configDoc = db.collection("config").document("config")
        configDoc.getDocument { document, error in
            guard error == nil else {
                print("Error: \(error?.localizedDescription ?? "")")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                
                let week = data?["week"] as? String ?? ""
                let picksDue = data?["picksDue"] as? String ?? ""
                self.config.week = week
                self.config.picksLock = picksDue
            } else {
                print("snapshot does not exist")
            }
        }
    }

    
    func getTeams() async {
        guard let url = URL(string: "https://api.collegefootballdata.com/teams/fbs?year=2023") else { fatalError("Missing URL") }

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

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}
