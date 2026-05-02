//
//  ParentalControlsSetupView.swift
//  Drift
//
//

import SwiftUI

struct ParentalControlsSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var parentalControls = ParentalControlsManager.shared

    @State private var step = 0 // 0: passcode, 1: security question
    @State private var passcode = ""
    @State private var confirmPasscode = ""
    @State private var selectedQuestion = ParentalControlsManager.securityQuestions[0]
    @State private var answer = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                if step == 0 {
                    // Step 1: Set passcode
                    Section {
                        SecureField("4-digit passcode", text: $passcode)
                            .keyboardType(.numberPad)
                            .onChange(of: passcode) { _, new in
                                if new.count > 4 {
                                    passcode = String(new.prefix(4))
                                }
                            }

                        SecureField("Confirm passcode", text: $confirmPasscode)
                            .keyboardType(.numberPad)
                            .onChange(of: confirmPasscode) { _, new in
                                if new.count > 4 {
                                    confirmPasscode = String(new.prefix(4))
                                }
                            }
                    } header: {
                        Text("Create Passcode")
                    } footer: {
                        Text("Enter a 4-digit passcode that will be required to stop focus sessions.")
                    }

                    if showError {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    Section {
                        Button("Next") {
                            validatePasscode()
                        }
                        .disabled(passcode.count != 4 || confirmPasscode.count != 4)
                    }
                } else {
                    // Step 2: Security question
                    Section {
                        Picker("Question", selection: $selectedQuestion) {
                            ForEach(ParentalControlsManager.securityQuestions, id: \.self) { question in
                                Text(question).tag(question)
                            }
                        }

                        TextField("Answer", text: $answer)
                            .autocapitalization(.none)
                    } header: {
                        Text("Security Question")
                    } footer: {
                        Text("This will be used to reset your passcode if you forget it.")
                    }

                    if showError {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    Section {
                        Button("Complete Setup") {
                            completeSetup()
                        }
                        .disabled(answer.isEmpty)
                    }
                }
            }
            .navigationTitle("Parental Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func validatePasscode() {
        guard passcode.count == 4, passcode.allSatisfy({ $0.isNumber }) else {
            showError = true
            errorMessage = "Passcode must be 4 digits"
            return
        }

        guard passcode == confirmPasscode else {
            showError = true
            errorMessage = "Passcodes don't match"
            return
        }

        showError = false
        step = 1
    }

    private func completeSetup() {
        guard !answer.isEmpty else {
            showError = true
            errorMessage = "Please enter an answer"
            return
        }

        let success = parentalControls.setupPasscode(passcode, question: selectedQuestion, answer: answer)

        if success {
            dismiss()
        } else {
            showError = true
            errorMessage = "Failed to save parental controls"
        }
    }
}

struct SecurityQuestionRecoveryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var parentalControls = ParentalControlsManager.shared

    @State private var answer = ""
    @State private var showError = false
    @State private var showResetPasscode = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let question = parentalControls.getSecurityQuestion() {
                        Text(question)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    TextField("Your answer", text: $answer)
                        .autocapitalization(.none)
                } header: {
                    Text("Security Question")
                } footer: {
                    Text("Answer your security question to reset your passcode.")
                }

                if showError {
                    Section {
                        Text("Incorrect answer. Please try again.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button("Verify") {
                        verifyAnswer()
                    }
                    .disabled(answer.isEmpty)
                }
            }
            .navigationTitle("Forgot Passcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showResetPasscode) {
                ResetPasscodeView()
            }
        }
    }

    private func verifyAnswer() {
        if parentalControls.verifySecurityAnswer(answer) {
            showError = false
            showResetPasscode = true
        } else {
            showError = true
            answer = ""
        }
    }
}

struct ResetPasscodeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var parentalControls = ParentalControlsManager.shared

    @State private var newPasscode = ""
    @State private var confirmPasscode = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("New 4-digit passcode", text: $newPasscode)
                        .keyboardType(.numberPad)
                        .onChange(of: newPasscode) { _, new in
                            if new.count > 4 {
                                newPasscode = String(new.prefix(4))
                            }
                        }

                    SecureField("Confirm new passcode", text: $confirmPasscode)
                        .keyboardType(.numberPad)
                        .onChange(of: confirmPasscode) { _, new in
                            if new.count > 4 {
                                confirmPasscode = String(new.prefix(4))
                            }
                        }
                } header: {
                    Text("Reset Passcode")
                } footer: {
                    Text("Enter a new 4-digit passcode.")
                }

                if showError {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button("Save New Passcode") {
                        resetPasscode()
                    }
                    .disabled(newPasscode.count != 4 || confirmPasscode.count != 4)
                }
            }
            .navigationTitle("Reset Passcode")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func resetPasscode() {
        guard newPasscode.count == 4, newPasscode.allSatisfy({ $0.isNumber }) else {
            showError = true
            errorMessage = "Passcode must be 4 digits"
            return
        }

        guard newPasscode == confirmPasscode else {
            showError = true
            errorMessage = "Passcodes don't match"
            return
        }

        if parentalControls.resetPasscode(newPasscode) {
            dismiss()
        } else {
            showError = true
            errorMessage = "Failed to reset passcode"
        }
    }
}

#Preview {
    ParentalControlsSetupView()
}
