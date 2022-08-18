//
//  PickTwoApp.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import SwiftUI
import Firebase

class AuthUser: ObservableObject {
    @Published var id: String?
}

class UserProfile: ObservableObject {
    @Published var id: String?
    @Published var currentPicks: [String]?
    @Published var name: String?
    @Published var previousPicks: [String]?
}


@main
struct PickTwoApp: App {
    @StateObject var user: AuthUser = AuthUser()
    @StateObject var network: Network = Network()
    @StateObject var userProfile: UserProfile = UserProfile()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        if user.id?.isEmpty ?? true {
            LoginView()
                .environmentObject(user)
                .environmentObject(network)
                .environmentObject(userProfile)
        } else {
            MainView()
                .environmentObject(user)
                .environmentObject(userProfile)
                .environmentObject(network)
        }
    }
}
