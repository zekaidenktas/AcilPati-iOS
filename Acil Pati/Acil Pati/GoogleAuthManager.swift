//
//  GoogleAuthManager.swift
//  Acil Pati
//
//  Created by Zekai Denktaş on 28.11.2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

final class GoogleAuthManager {
    static let shared = GoogleAuthManager()
    private init() {}
    
    @MainActor
    func signIn() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController  else {
            return
        }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            return
        }
        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: accessToken)
        try await Auth.auth().signIn(with: credential)
            
        
    }
}
    
