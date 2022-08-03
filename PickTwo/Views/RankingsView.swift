//
//  ContentView.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import SwiftUI
import Foundation

struct RankingsView: View {
    @EnvironmentObject var network: Network
    
    var body: some View {
        TeamsListView()
            .onAppear {
                network.getRankings()
                network.getTeams()
            }
    }
    
}

struct TeamsListView: View {
    @State private var selection: Team?
    @State private var selections: [Team] = []
    @State private var showSubmit: Bool = false
    @EnvironmentObject var network: Network
    
    var body: some View {
        VStack {
            list
            if showSubmit {
                Button(action: {
                }) {
                    Text("Submit Picks")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(40)
                        .foregroundColor(.white)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.green, lineWidth: 5)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(Color.white)
            }
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
                    Text("Pick Team")
                        .foregroundColor(Color.blue)
                }
            }
            .onTapGesture { self.selectDeselect(team) }
            .listRowBackground(selections.contains(where: {$0.school == team.school}) ? Color.green : Color.white)
        }
        .listStyle(.automatic)
    }
    
    private func selectDeselect(_ team: Team) {
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


