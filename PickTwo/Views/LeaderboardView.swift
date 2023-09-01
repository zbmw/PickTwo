//
//  LeaderboardView.swift
//  PickTwo
//
//  Created by Brett Walton on 8/3/22.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var network: Network
    @EnvironmentObject var userProfile: UserProfile

    var body: some View {
        let date = Date()
        let lockTime = network.translateDate(dateString: network.config.picksLock ?? "") ?? Date()
        if Date() < network.translateDate(dateString: network.config.picksLock ?? "") ?? Date() {
            List {
                Section(header: HStack{
                    Text("Name")
                    Spacer()
                    Text("Strikes")
                }) {
                    ForEach(network.standings.sorted(by: <), id: \.key) { key, value in
                        HStack {
                            Text("\(key)")
                            Spacer()
                            Text("\(value)")
                        }
                    }
                }
            }
        } else {
            ScrollView {
                VStack {
                    ForEach(network.users, id: \.name) { picks in
                        List {
                            Section(header: HStack {
                                Text("\(picks.name)")
                                    .bold()
                                Spacer()
                                Text("Strikes: \(picks.strikes)")}, content: {
                                    ForEach(picks.currentPicks ?? [], id: \.self) { pick in
                                        Text("\(pick)")
                                    }
                                })
                        }
                        .disabled(true)
                        .frame(width: UIScreen.main.bounds.width, height: 150, alignment: .leading)
                    }
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
