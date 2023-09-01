//
//  PoolPicks.swift
//  PickTwo
//
//  Created by Brett Walton on 9/1/23.
//

import Foundation
import SwiftUI

struct PoolPicksView: View {
    @EnvironmentObject var network: Network
    var body: some View {
        if Date() < network.translateDate(dateString: network.config.picksLock ?? "") ?? Date() {
            placeholderView
        } else {
            list
        }
    }
    
    var list: some View {
        let users = network.users
        return List(network.rankedTeams, id: \.school) { team in
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
                }
                Spacer(minLength: .leastNonzeroMagnitude)
                VStack(alignment: .leading) {
                    ForEach(users, id: \.name) { user in
                        if let picks = user.currentPicks,
                           picks.contains("\(team.school)") {
                            Text("  -\(user.name)")
                        }
                    }
                }
            }
        }
        .listStyle(.automatic)
    }
    
    var placeholderView: some View {
        VStack(alignment: .center) {
            Text("Check back after picks lock, or switch tabs & come back")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
}
