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
    @State var hasUsername: Bool = false
    
    
    var body: some View {
        TabView {
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
            }
            NavigationView {
                LeaderboardView()
                    .environmentObject(network)
                    .navigationTitle("Leaderboard")
            }
            .tabItem {
                Image(systemName: "chart.bar")
                    .padding()
                Text("Leaderboard")
            }
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
            }
        }.onAppear() {
            self.getUser()
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
               }
           }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
