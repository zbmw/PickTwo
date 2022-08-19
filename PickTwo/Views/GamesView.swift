//
//  GamesView.swift
//  PickTwo
//
//  Created by Brett Walton on 8/18/22.
//

import SwiftUI

struct GamesView: View {
    @EnvironmentObject var network: Network
    
    var body: some View {
        List(network.rankedMatchups, id: \.homeTeam) { game in
            HStack {
                let date: String = network.translateDate(game: game) ?? ""
                let dateTime = date.split(separator: ",")
                let dayte = dateTime.first
                let time = dateTime.last

                VStack {
                    Text("\(String(describing: dayte ?? ""))")
                    Text("\(String(describing: time ?? ""))")
                }
                VStack(alignment: .leading) {
                    HStack {
                        let homeTeam = network.teams.first(where: {$0.school == game.homeTeam})
                        AsyncImage(url: URL(string: homeTeam?.logos?.first ?? "")) { image in image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Image(systemName: "questionmark.circle.fill")
                        }
                        .frame(width: 35, height: 35, alignment: .trailing)
                        Text("\(network.rankingForTeam(team: game.homeTeam) ?? "")")
                            .foregroundColor(Color(UIColor.systemGray3))
                            .font(.caption)
                        Text("\(game.homeTeam)")
                        Spacer()
                        Text("\(game.homePoints ?? 0)")
                    }
                    .padding()
                    HStack {
                        let awayTeam = network.teams.first(where: {$0.school == game.awayTeam})
                        AsyncImage(url: URL(string: awayTeam?.logos?.first ?? "")) { image in image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Image(systemName: "questionmark.circle.fill")
                        }
                        .frame(width: 35, height: 35, alignment: .trailing)
                        Text("\(network.rankingForTeam(team: game.awayTeam) ?? "")")
                            .foregroundColor(Color(UIColor.systemGray3))
                            .font(.caption)
                        Text("\(game.awayTeam)")
                        Spacer()
                        Text("\(game.awayPoints ?? 0)")
                    }
                    .padding()
                }
            }
        }
        .onAppear() {
            if network.rankedMatchups.isEmpty {
                network.getMatchups()
            }
        }
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
    }
}
