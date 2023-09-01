//
//  MainView.swift
//  PickTwo
//
//  Created by Brett Walton on 8/3/22.
//

import SwiftUI
import Firebase
import FirebaseMessaging

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
                                Task { //DispatchQueue.main.async {
                                    await self.network.getConfig()
                                    await self.network.getRankings()
                                    await network.getTeams()
                                    self.getUser()
                                }
                            }
                            .foregroundColor(Color.white)
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
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
                                self.network.matchups = []
                                Task {
                                    await self.network.getConfig()
                                    await self.network.getRankings()
                                    await network.getTeams()
                                    self.getUser()
                                    network.getMatchups()
                                }
                            }
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "sportscourt")
                    .padding()
                Text("Matchups")
                GamesView.init(matchups: network.rankedMatchups)
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
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "chart.bar")
                    .padding()
                Text("Leaderboard")
            }.tag(3)
            NavigationView {
                ProfileView()
                    .environmentObject(network)
                    .environmentObject(userProfile)
                    .environmentObject(user)
                    .navigationTitle("Profile")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                self.getUser()
                            }
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
            
            .tabItem {
                Image(systemName: "person")
                    .padding()
                Text("Profile/Picks")
            }.tag(4)
            NavigationView {
                PoolPicksView()
                    .environmentObject(network)
                    .environmentObject(userProfile)
                    //.environmentObject(user)
                    .navigationTitle("Pool Picks this week:")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Refresh") {
                                self.getUser()
                            }
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
            
            .tabItem {
                Image(systemName: "chart.pie")
                    .padding()
                Text("Pool Picks")
            }.tag(5)
        }.onAppear() {
            if network.fcmToken?.isEmpty ?? true {
                Messaging.messaging().token { token, error in
                  if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                  } else if let token = token {
                      network.fcmToken = token
                    print("FCM registration token: \(token)")
                    print("Remote FCM registration token: \(token)")
                  }
                }
            }
            self.getUser()
            Task {
                network.standings = network.getAllUsers() ?? [:]
                network.getAllPicks()
                await network.getTeams()
            }
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
