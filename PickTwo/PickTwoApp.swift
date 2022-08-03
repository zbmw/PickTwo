//
//  PickTwoApp.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import SwiftUI

@main
struct PickTwoApp: App {
    var network = Network()
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    RankingsView()
                        .environmentObject(network)
                        .navigationTitle("Top 25")
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
                    LeaderboardView()
                        .environmentObject(network)
                        .navigationTitle("Profile")
                }
                .tabItem {
                    Image(systemName: "person")
                        .padding()
                    Text("Profile/Picks")
                }
            }
        }
    }
}
