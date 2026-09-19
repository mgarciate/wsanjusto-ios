//
//  AutenticationService.swift
//  wsanjusto-ios
//
//  Created by mgarciate on 14/07/2021.
//

import Foundation
@preconcurrency import FirebaseAuth
import AuthenticationServices
import CryptoKit

// Owns Firebase's opaque listener registration and removes it on teardown.
private final class AuthenticationStateObservation: @unchecked Sendable {
    private let auth: Auth
    private let handle: AuthStateDidChangeListenerHandle

    init(auth: Auth, handle: AuthStateDidChangeListenerHandle) {
        self.auth = auth
        self.handle = handle
    }

    deinit {
        auth.removeStateDidChangeListener(handle)
    }
}

@MainActor
class AuthenticationService: ObservableObject {
    enum AuthenticationError: Error {
        case missingCurrentUser
        case missingUpdatedUser
    }
    
    @Published var user: User?
    
    private var stateObservation: AuthenticationStateObservation?
    private var hasStarted = false
    private let stateListenerStarter: (@MainActor () -> Void)?

    init(
        isEnabled: Bool = false,
        stateListenerStarter: (@MainActor () -> Void)? = nil
    ) {
        self.stateListenerStarter = stateListenerStarter

        if isEnabled {
            start()
        }
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        if let stateListenerStarter {
            stateListenerStarter()
        } else {
            registerStateListener()
        }
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
    
    func updateDisplayName(displayName: String) async throws -> User {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationError.missingCurrentUser
        }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        let userID = user.uid
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            changeRequest.commitChanges { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        guard let updatedUser = Auth.auth().currentUser else {
            throw AuthenticationError.missingUpdatedUser
        }
        #if DEBUG
        print("Successfully updated display name for user [\(userID)] to [\(updatedUser.displayName ?? "(empty)")]")
        #endif
        self.user = updatedUser
        return updatedUser
    }
    
    private func registerStateListener() {
        let auth = Auth.auth()
        let handle = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.handleAuthenticationStateChange(user: user)
            }
        }
        stateObservation = AuthenticationStateObservation(auth: auth, handle: handle)
    }

    private func handleAuthenticationStateChange(user: User?) {
        #if DEBUG
        print("Sign in state has changed.")
        #endif
        self.user = user

        if let user {
            #if DEBUG
            let anonymous = user.isAnonymous ? "anonymously " : ""
            print("User signed in \(anonymous)with user ID \(user.uid). Email: \(user.email ?? "(empty)"), display name: [\(user.displayName ?? "(empty)")]")
            #endif
        } else {
            #if DEBUG
            print("User signed out.")
            #endif
            signIn()
        }
    }
}
