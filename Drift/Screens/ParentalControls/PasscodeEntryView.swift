//
//  PasscodeEntryView.swift
//  Drift
//
//

import SwiftUI

struct PasscodeEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let showForgotButton: Bool
    let onSuccess: () -> Void
    let onForgot: () -> Void

    @State private var passcode: String = ""
    @State private var showError: Bool = false
    @StateObject private var parentalControls = ParentalControlsManager.shared

    init(title: String = "Enter Passcode", showForgotButton: Bool = true, onSuccess: @escaping () -> Void, onForgot: @escaping () -> Void = {}) {
        self.title = title
        self.showForgotButton = showForgotButton
        self.onSuccess = onSuccess
        self.onForgot = onForgot
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                // Passcode dots
                HStack(spacing: 16) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index < passcode.count ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 16, height: 16)
                    }
                }

                if showError {
                    Text("Incorrect passcode")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            // Number pad
            VStack(spacing: 16) {
                ForEach(0..<3) { row in
                    HStack(spacing: 24) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            NumberButton(number: "\(number)") {
                                addDigit(String(number))
                            }
                        }
                    }
                }

                // Bottom row: 0 and delete
                HStack(spacing: 24) {
                    Color.clear.frame(width: 80, height: 80) // Spacer
                    NumberButton(number: "0") {
                        addDigit("0")
                    }
                    Button(action: deleteDigit) {
                        Image(systemName: "delete.left")
                            .font(.title2)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.primary)
                    }
                }
            }

            if showForgotButton {
                Button("Forgot Passcode?") {
                    onForgot()
                }
                .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }

    private func addDigit(_ digit: String) {
        guard passcode.count < 4 else { return }
        passcode += digit

        if passcode.count == 4 {
            // Auto-validate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                validatePasscode()
            }
        }
    }

    private func deleteDigit() {
        if !passcode.isEmpty {
            passcode.removeLast()
        }
        showError = false
    }

    private func validatePasscode() {
        if parentalControls.verifyPasscode(passcode) {
            onSuccess()
            dismiss()
        } else {
            showError = true
            passcode = ""
        }
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.title)
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(40)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    PasscodeEntryView(onSuccess: {}, onForgot: {})
}
