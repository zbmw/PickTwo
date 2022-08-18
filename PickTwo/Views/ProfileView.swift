//
//  ProfileView.swift
//  PickTwo
//
//  Created by Brett Walton on 8/3/22.
//

import SwiftUI

struct ProfileView: View {
    @State var name: String = ""
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var network: Network
    
    var body: some View {
        VStack {
            if userProfile.name?.isEmpty ?? true {
                Form {
                    TextField("Please Enter Your Name", text: $name) {
                        userProfile.name = name
                        network.setName(id: userProfile.id ?? "", name: name)
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Welcome back, \(userProfile.name ?? "")!")
                        .padding()
                        .font(.title)
                    Text("Your Picks:")
                        .font(.largeTitle)
                        .padding()
                    List(userProfile.currentPicks ?? [], id: \.self) { team in
                        Text("\(team)")
                    }
                    Text("Previous Picks:")
                        .padding()
                    if let prevPicks = userProfile.previousPicks, prevPicks.isEmpty {
                        Text("No picks yet.")
                            .padding()
                    } else {
                        List(userProfile.previousPicks ?? ["No picks yet."], id: \.self) { team in
                            if let prevPicks = userProfile.previousPicks, prevPicks.isEmpty {
                                Text("No picks yet.")
                            } else {
                                Text("\(team)")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
