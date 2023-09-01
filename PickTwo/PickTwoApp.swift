//
//  PickTwoApp.swift
//  PickTwo
//
//  Created by Brett Walton on 7/31/22.
//

import SwiftUI
import Firebase
import FirebaseMessaging

class AuthUser: ObservableObject {
    @Published var id: String?
    
    func logout() {
        try? Auth.auth().signOut()
        id = nil
    }
}

class UserProfile: ObservableObject {
    @Published var id: String?
    @Published var currentPicks: [String]?
    @Published var name: String?
    @Published var previousPicks: [String]?
    
    func clearInfo() {
        id = nil
        currentPicks = nil
        name = nil
        previousPicks = nil
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var network = Network()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        network.fcmToken = fcmToken
    }
}


@main
struct PickTwoApp: App {
    @StateObject var user: AuthUser = AuthUser()
    @StateObject var network: Network = Network()
    @StateObject var userProfile: UserProfile = UserProfile()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
                .environmentObject(appDelegate.network)
                .environmentObject(userProfile)
        } else {
            MainView()
                .environmentObject(user)
                .environmentObject(userProfile)
                .environmentObject(appDelegate.network)
        }
    }
}
