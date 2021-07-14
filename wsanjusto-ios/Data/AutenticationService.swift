//
//  AutenticationService.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation
import Firebase
import AuthenticationServices
import CryptoKit

class AuthenticationService: ObservableObject {
    
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        registerStateListener()
    }
    
    func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("Error when trying to sign out: \(error.localizedDescription)")
        }
    }
    
    func updateDisplayName(displayName: String, completionHandler: @escaping (Result<User, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    completionHandler(.failure(error))
                }
                else {
                    if let updatedUser = Auth.auth().currentUser {
                        print("Successfully updated display name for user [\(user.uid)] to [\(updatedUser.displayName ?? "(empty)")]")
                        // force update the local user to trigger the publisher
                        self.user = updatedUser
                        completionHandler(.success(updatedUser))
                    }
                }
            }
        }
    }
    
    private func registerStateListener() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("Sign in state has changed.")
            self.user = user
            
            if let user = user {
                let anonymous = user.isAnonymous ? "anonymously " : ""
                print("User signed in \(anonymous)with user ID \(user.uid). Email: \(user.email ?? "(empty)"), display name: [\(user.displayName ?? "(empty)")]")
            }
            else {
                print("User signed out.")
                self.signIn()
            }
        }
    }
}
