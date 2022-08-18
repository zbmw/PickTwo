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
                    Text("Welcome Back, \(userProfile.name ?? "")!")
                        .padding()
                        .font(.title)
                    List {
                        Section(header: Text("Your Picks This Week:")) {
                            ForEach(userProfile.currentPicks ?? [], id: \.self) { team in
                                Text("\(team)")
                            }
                        }
                        Section(header: Text("Previously picked teams:")) {
                            if let prevPicks = userProfile.previousPicks, prevPicks.isEmpty {
                                Text("No picks yet.")
                                    .padding()
                            } else {
                                ForEach(userProfile.previousPicks ?? [], id: \.self) { team in
                                    Text("\(team)")
                                }
                            }
                        }
                    }.listStyle(.insetGrouped)
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
