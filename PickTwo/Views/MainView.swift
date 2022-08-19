//
//  MainView.swift
//  PickTwo
//
//  Created by Brett Walton on 8/3/22.
//

import SwiftUI
import Firebase

struct MainView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var network: Network
    @EnvironmentObject var user: AuthUser
    @State var selection: Int = 4
    
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                RankingsView()
                    .environmentObject(network)
                    .environmentObject(userProfile)
                    .navigationTitle("Top 25")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                self.getUser()
                            }
                        }
                    }
            }
            .tabItem {
                Image(systemName: "list.number")
                    .padding()
                Text("Top 25")
            }.tag(1)
            NavigationView {
                GamesView()
                    .environmentObject(network)
                    .navigationTitle("Matchups")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                network.getMatchups()
                            }
                        }
                    }
            }
            .tabItem {
                Image(systemName: "sportscourt")
                    .padding()
                Text("Matchups")
            }.tag(2)
            NavigationView {
                LeaderboardView()
                    .environmentObject(network)
                    .environmentObject(userProfile)
                    .navigationTitle("Leaderboard")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                network.getAllUsers()
                            }
                        }
                    }
            }
            .tabItem {
                Image(systemName: "chart.bar")
                    .padding()
                Text("Leaderboard")
            }.tag(3)
            NavigationView {
                ProfileView()
                    .environmentObject(network)
                    .environmentObject(userProfile)
                    .navigationTitle("Profile")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                self.getUser()
                            }
                        }
                    }
            }
            
            .tabItem {
                Image(systemName: "person")
                    .padding()
                Text("Profile/Picks")
            }.tag(4)
        }.onAppear() {
            self.getUser()
            network.standings = network.getAllUsers() ?? [:]
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
                       self.userProfile.id = data["uid"] as? String ?? ""
                       self.userProfile.currentPicks = data["currentPicks"] as? [String] ?? []
                       self.userProfile.name = data["name"] as? String ?? ""
                       self.userProfile.previousPicks = data["previousPicks"] as? [String] ?? []
                   }
               } else {
                   db.collection("users").document(id).setData({["uid":id]}())
               }
           }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
