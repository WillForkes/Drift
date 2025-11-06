//
//  ParentalControlsManager.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import Foundation
import Security

/// Manages parental controls passcode and security
@MainActor
class ParentalControlsManager: ObservableObject {
    static let shared = ParentalControlsManager()

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Constants.enabledKey)
        }
    }

    private enum Constants {
        static let enabledKey = "drift.parental.enabled"
        static let passcodeKey = "drift.parental.passcode"
        static let questionKey = "drift.parental.question"
        static let answerKey = "drift.parental.answer"
    }

    // Common security questions
    static let securityQuestions = [
        "What was the name of your first pet?",
        "What city were you born in?",
        "What is your mother's maiden name?",
        "What was the name of your first school?",
        "What is your favorite book?"
    ]

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: Constants.enabledKey)
    }

    // MARK: - Setup

    /// Set up parental controls with passcode and security question
    func setupPasscode(_ passcode: String, question: String, answer: String) -> Bool {
        guard passcode.count == 4, passcode.allSatisfy({ $0.isNumber }) else {
            return false
        }

        guard !answer.isEmpty else {
            return false
        }

        // Save to keychain
        _ = saveToKeychain(key: Constants.passcodeKey, value: passcode)
        _ = saveToKeychain(key: Constants.questionKey, value: question)
        _ = saveToKeychain(key: Constants.answerKey, value: answer.lowercased())

        isEnabled = true
        return true
    }

    // MARK: - Verification

    /// Verify the entered passcode
    func verifyPasscode(_ passcode: String) -> Bool {
        guard let stored = retrieveFromKeychain(key: Constants.passcodeKey) else {
            return false
        }
        return passcode == stored
    }

    /// Verify security answer and allow passcode reset
    func verifySecurityAnswer(_ answer: String) -> Bool {
        guard let stored = retrieveFromKeychain(key: Constants.answerKey) else {
            return false
        }
        return answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == stored
    }

    /// Get the security question
    func getSecurityQuestion() -> String? {
        return retrieveFromKeychain(key: Constants.questionKey)
    }

    // MARK: - Reset

    /// Reset/change the passcode (requires current passcode or security answer)
    func resetPasscode(_ newPasscode: String) -> Bool {
        guard newPasscode.count == 4, newPasscode.allSatisfy({ $0.isNumber }) else {
            return false
        }

        return saveToKeychain(key: Constants.passcodeKey, value: newPasscode)
    }

    /// Disable parental controls
    func disable() {
        isEnabled = false
        // Optionally clear keychain data
        deleteFromKeychain(key: Constants.passcodeKey)
        deleteFromKeychain(key: Constants.questionKey)
        deleteFromKeychain(key: Constants.answerKey)
    }

    // MARK: - Debug/Reset

    /// Clear all parental controls data (for development/testing)
    func resetAllData() {
        disable()
    }

    // MARK: - Keychain Helpers

    private func saveToKeychain(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete existing item first
        deleteFromKeychain(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func retrieveFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
