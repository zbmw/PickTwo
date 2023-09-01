//
//  ContentView.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import SwiftUI
import Foundation
import Firebase

struct RankingsView: View {
    @EnvironmentObject var network: Network
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var authUser: AuthUser
    
    
    var body: some View {
        TeamsListView()
            .environmentObject(userProfile)
            .environmentObject(network)
            .environmentObject(authUser)
            .onAppear {
                if network.rankedTeams.isEmpty {
                    Task {
                        await network.getRankings()
                        await network.getTeams()
                    }
                }
        }
    }
}

struct TeamsListView: View {
    @State private var selection: Team?
    @State private var selections: [Team] = []
    @State private var showSubmit: Bool = false
    @State private var showSubmissionSuccess: Bool = false
    @EnvironmentObject var network: Network
    @EnvironmentObject var user: UserProfile
    @EnvironmentObject var authUser: AuthUser
    @Environment(\.colorScheme) var colorScheme
    var canMakePicks: Bool {
        if Date() < network.translateDate(dateString: network.config.picksLock ?? "") ?? Date() {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            if canMakePicks {
            let dateString = network.config.picksLock as? String
                Text("Picks Lock at:\n\(network.translateDate(date: dateString ?? "") ?? "TBD")")
                .lineLimit(nil)
                .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                .background(Color.red.opacity(0.8))
                .padding()
            } else {
                Text("Picks are locked... \nHope you made the right ones!")
                    .lineLimit(nil)
                    .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .center)
                    .background(Color.green.opacity(0.7))
                    .padding()
            }
            list
            if showSubmit {
                Button(action: {
                    if canMakePicks {
                        network.setPicks(picks: selections, id: authUser.id ?? "", name: user.name ?? "", previousPicks: user.previousPicks ?? [])
                        showSubmit = false
                        selections.removeAll()
                        showSubmissionSuccess = true
                        self.getUser()
                    } else {
                        print("Submission failed")
                    }
                }) {
                    Text("Submit Picks")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(40)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(10)
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(.blue.opacity(0.2))
            }
        }
        .alert(isPresented: $showSubmissionSuccess) {
            Alert(title: Text("Your Picks were submitted!"), message: Text("Thanks for setting your picks, please refresh to see your new picks."),
                  dismissButton: .default(Text("Okay")) {
                        showSubmissionSuccess = false
                    }
            )
        }
        
    }
    
    var list: some View {
        List(network.rankedTeams, id: \.school) { team in
            VStack(alignment: .leading) {
                HStack {
                    Text("\(String(describing: (team.rank ?? 0) as Int)). ")
                    Text(team.school)
                        .padding()
                    AsyncImage(url: URL(string: team.logos?.first ?? "")) { image in image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color(red: 12, green: 32, blue: 32)
                    }
                    .frame(width: 35, height: 35, alignment: .trailing)
                    Spacer()
                    if team.school == user.currentPicks?.first || team.school == user.currentPicks?.last {
                        Text("Current Pick")
                            .foregroundColor(Color.yellow)
                    } else {
                        Text("Pick Team")
                            .foregroundColor(Color.blue)
                    }
                }
            }
            .onTapGesture {
                if canMakePicks {
                    self.selectDeselect(team)
                }
            }
            .listRowBackground(self.colorCells(team: team))
        }
        .listStyle(.automatic)
    }
    
    private func selectDeselect(_ team: Team) {
        if let prevPicks = user.previousPicks, prevPicks.contains(where: {$0.self == team.school}) {
            print("Cannot select team, already picked.")
            return
        }
        
        if selections.contains(where: {$0.school == team.school}) {
            let index = selections.firstIndex(where: {$0.school == team.school})
            selections.remove(at: index ?? 0)
        } else if selections.count < 2 {
            selections.append(team)
        }
        
        if selections.count == 2 {
            showSubmit = true
        } else {
            showSubmit = false
        }
    }
    
    private func colorCells(team: Team) -> Color {
        if let prevPicks = user.previousPicks, prevPicks.contains(where: {$0.self == team.school}) {
            return Color.red.opacity(0.6)
        } else if selections.contains(where: {$0.school == team.school}) {
            return Color.green.opacity(0.6)
        } else {
            return colorScheme == .dark ? Color(UIColor.systemGray5) : Color.white
        }
    }
    
    func getUser() {
        guard let id = user.id else {
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(id)

           docRef.getDocument { (document, error) in
               guard error == nil else {
                   print("error", error ?? "")
                   return
               }

               if let document = document, document.exists {
                   let data = document.data()
                   if let data = data {
                       print("data", data)
                       self.user.id = data["uid"] as? String ?? ""
                       self.user.currentPicks = data["currentPicks"] as? [String] ?? []
                       self.user.name = data["name"] as? String ?? ""
                       self.user.previousPicks = data["previousPicks"] as? [String] ?? []
                   }
               } else {
                   db.collection("users").document(id).setData({["uid":id]}())
               }
           }
    }
    
}


struct TeamView: View {
    let team: Team
    @EnvironmentObject var network: Network
    @State private var selection: Team?
    
    var body: some View {
        HStack {
            content
            Spacer()
        }
        .contentShape(Rectangle())
        
    }
    
    private var content: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(String(describing: (team.rank ?? 0) as Int)). ")
                Text(team.school)
                    .padding()
                AsyncImage(url: URL(string: team.logos?.first ?? "")) { image in image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color(red: 12, green: 32, blue: 32)
                }
                .frame(width: 35, height: 35, alignment: .trailing)
                Spacer()
                Button("Select", action: {
                    let selected = network.rankedTeams.first(where: {$0.school == team.school})?.currentPick ?? false
                    if selected {
                        network.rankedTeams.first(where: {$0.school == team.school})?.currentPick = false
                    } else {
                        network.rankedTeams.first(where: {$0.school == team.school})?.currentPick = true
                        
                    }
                })
                .onTapGesture {
                    let selected = network.rankedTeams.first(where: {$0.school == team.school})?.currentPick ?? false
                    if selected {
                        network.rankedTeams.first(where: {$0.school == team.school})?.currentPick = false
                    } else {
                        network.rankedTeams.first(where: {$0.school == team.school})?.currentPick = true
                        
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RankingsView()
    }
}


