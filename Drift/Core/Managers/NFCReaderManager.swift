//
//  NFCReaderManager.swift
//  Drift
//
//  Created by Claude Code on 05/11/2025.
//

import Foundation
import CoreNFC
import Combine

@MainActor
class NFCReaderManager: NSObject, ObservableObject {
    static let shared = NFCReaderManager()

    @Published var isScanning: Bool = false
    @Published var detectedTagId: String?
    @Published var errorMessage: String?

    private var nfcSession: NFCNDEFReaderSession?
    private var scanCompletion: ((Result<String, NFCScanError>) -> Void)?

    private override init() {
        super.init()
    }

    /// Start scanning for NFC tags
    func startScanning(completion: ((Result<String, NFCScanError>) -> Void)? = nil) {
        // Store completion handler
        scanCompletion = completion

        // Clear previous state
        detectedTagId = nil
        errorMessage = nil

        // Check if NFC is available on this device
        guard NFCNDEFReaderSession.readingAvailable else {
            print("❌ [NFC] Not available on this device")
            errorMessage = "NFC is not available on this device"
            scanCompletion?(.failure(.notAvailable))
            scanCompletion = nil
            return
        }

        // Create and start NFC session
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the Drift device"
        nfcSession?.begin()

        isScanning = true
    }

    /// Stop scanning for NFC tags
    func stopScanning() {
        nfcSession?.invalidate()
        nfcSession = nil
        isScanning = false
    }

    /// Parse tag ID from URL string
    /// Expected format: https://get-drift.app/focus?id=1234
    private func parseTagId(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let tagId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            return nil
        }
        return tagId
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCReaderManager: NFCNDEFReaderSessionDelegate {

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            isScanning = false

            // Check if it's a user cancellation (not really an error)
            if let nfcError = error as? NFCReaderError {
                switch nfcError.code {
                case .readerSessionInvalidationErrorUserCanceled:
                    // User cancelled - don't show error
                    errorMessage = nil
                    scanCompletion?(.failure(.userCancelled))
                    scanCompletion = nil
                case .readerSessionInvalidationErrorFirstNDEFTagRead:
                    // Successfully read tag - this is actually success
                    errorMessage = nil
                case .readerSessionInvalidationErrorSessionTimeout:
                    print("⏱️ [NFC] Scan timed out")
                    errorMessage = "Scanning timed out. Please try again."
                    scanCompletion?(.failure(.timeout))
                    scanCompletion = nil
                default:
                    // Check if it's a 200-level code (success states)
                    let errorCode = nfcError.code.rawValue
                    if errorCode >= 200 && errorCode < 300 {
                        // 200-level codes are success states, not errors
                        errorMessage = nil
                    } else {
                        print("❌ [NFC] Error: \(errorCode)")
                        errorMessage = "NFC scanning error. Please try again."
                    }
                }
            }
        }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        Task { @MainActor in
            // Parse NDEF messages for URL records
            for message in messages {
                for record in message.records {
                    // Check if this is a URI record
                    if record.typeNameFormat == .nfcWellKnown {
                        // Try to get URL from payload
                        if let url = record.wellKnownTypeURIPayload()?.absoluteString {
                            if let tagId = parseTagId(from: url) {
                                print("✅ [NFC] Tag ID: \(tagId)")
                                detectedTagId = tagId
                                session.alertMessage = "Drift detected!"
                                scanCompletion?(.success(tagId))
                                scanCompletion = nil
                                session.invalidate()
                                return
                            }
                        }
                    }

                    // Also check absoluteURI (alternative way to get URL)
                    if let payload = String(data: record.payload, encoding: .utf8) {
                        // Some NFC tags encode the URL in the payload directly
                        if payload.contains("get-drift.app"), let tagId = parseTagId(from: payload) {
                            print("✅ [NFC] Tag ID: \(tagId)")
                            detectedTagId = tagId
                            session.alertMessage = "Drift detected!"
                            scanCompletion?(.success(tagId))
                            scanCompletion = nil
                            session.invalidate()
                            return
                        }
                    }
                }
            }

            // If we get here, no valid tag was found
            print("❌ [NFC] Invalid Drift tag")
            errorMessage = "Invalid Drift tag. Please use an official Drift device."
            scanCompletion?(.failure(.invalidTag))
            scanCompletion = nil
            session.invalidate()
        }
    }
}

// MARK: - NFCScanError

enum NFCScanError: LocalizedError {
    case notAvailable
    case userCancelled
    case timeout
    case invalidTag
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "NFC is not available on this device"
        case .userCancelled:
            return "Scan cancelled by user"
        case .timeout:
            return "Scanning timed out. Please try again."
        case .invalidTag:
            return "Invalid Drift tag. Please use an official Drift device."
        case .unknown:
            return "Unknown NFC error occurred"
        }
    }
}

