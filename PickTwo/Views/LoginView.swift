//
//  LoginView.swift
//  PickTwo
//
//  Created by Brett Walton on 8/3/22.
//

import SwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices

struct LoginView: View {
    @State var currentNonce: String?
    @EnvironmentObject var user: AuthUser
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var network: Network
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to the 2022 Pick-Two Pool!")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding()
                    .padding()
                SignInWithAppleButton(.signIn) { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        switch authResults.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            
                            guard let nonce = currentNonce else {
                                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                            }
                            guard let appleIDToken = appleIDCredential.identityToken else {
                                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                            }
                            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                return
                            }
                            
                            let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                            Auth.auth().signIn(with: credential) { (authResult, error) in
                                if (error != nil) {
                                    print(error?.localizedDescription as Any)
                                    return
                                }
                                print("signed in")
                                Task {
                                    await network.getConfig()
                                    user.id = authResult?.user.uid
                                    network.user?.id = authResult?.user.uid
                                    userProfile.id = authResult?.user.uid
                                    await network.getTeams()
                                    await network.getRankings()
                                    await network.getMatchups()
                                }
                            }
        
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
                .padding()
                .signInWithAppleButtonStyle(colorScheme == .light ? .black : .whiteOutline)
                .frame(width: 280, height: 80, alignment: .center)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    ///MARK: Encoding for Apple Login
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789abcdefghijklmnopqrstuvxyzabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaininglength = length
        
        while remaininglength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("unable to generate nonce. secrandomcopybytes failed with osstatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remaininglength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remaininglength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputdata = Data(input.utf8)
        let hasheddata = SHA256.hash(data: inputdata)
        let hashstring = hasheddata.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashstring
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
