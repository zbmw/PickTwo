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
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
