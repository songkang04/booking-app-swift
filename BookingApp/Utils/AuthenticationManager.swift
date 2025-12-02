//
//  AuthenticationManager.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var requiresOTPVerification: Bool = false
    @Published var pendingVerificationEmail: String = ""

    private let userDefaultsKey = "LoggedInUser"

    init() {
        loadUserFromDefaults()
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        print("🔐 [AUTH] Attempting login with email: \(email)")

        do {
            // Validate inputs
            if email.isEmpty || password.isEmpty {
                errorMessage = "Email and password are required"
                isLoading = false
                print("❌ [AUTH] Validation failed: Empty email or password")
                return
            }

            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
                isLoading = false
                print("❌ [AUTH] Validation failed: Password too short")
                return
            }

            // Prepare request
            guard let url = URL(string: "http://localhost:3000/api/auth/login") else {
                errorMessage = "Invalid URL"
                isLoading = false
                print("❌ [AUTH] Invalid API URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "accept")

            // Prepare request body
            let requestBody: [String: String] = [
                "email": email,
                "password": password
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            print("📤 [AUTH] Sending login request to \(url.absoluteString)")

            // Make API call
            let (data, response) = try await URLSession.shared.data(for: request)

            print("📥 [AUTH] Received response from server")

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response"
                isLoading = false
                print("❌ [AUTH] Invalid HTTP response")
                return
            }

            print("📊 [AUTH] HTTP Status Code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Parse response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("🔍 [AUTH] Response JSON: \(jsonResponse)")

                    // Try to get user from data.user path
                    var userDict: [String: Any]? = nil

                    // First try: data.user._doc (MongoDB Mongoose format)
                    if let dataDict = jsonResponse["data"] as? [String: Any],
                       let userObj = dataDict["user"] as? [String: Any],
                       let docDict = userObj["_doc"] as? [String: Any] {
                        userDict = docDict
                        print("📍 [AUTH] Found user at data.user._doc")
                    }
                    // Second try: data.user (direct user object)
                    else if let dataDict = jsonResponse["data"] as? [String: Any],
                            let userObj = dataDict["user"] as? [String: Any] {
                        userDict = userObj
                        print("📍 [AUTH] Found user at data.user")
                    }
                    // Third try: user (legacy format)
                    else if let userObj = jsonResponse["user"] as? [String: Any] {
                        userDict = userObj
                        print("📍 [AUTH] Found user at user")
                    }

                    // Extract and save auth token
                    if let dataDict = jsonResponse["data"] as? [String: Any] {
                        if let token = dataDict["token"] as? String {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            print("🔑 [AUTH] Token saved: \(token.prefix(20))...")
                        } else if let token = dataDict["accessToken"] as? String {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            print("🔑 [AUTH] AccessToken saved: \(token.prefix(20))...")
                        }
                    }

                    if let userDict = userDict,
                       let userId = userDict["_id"] as? String,
                       let firstName = userDict["firstName"] as? String {

                        // Create user object
                        let user = User(
                            id: userId,
                            email: email,
                            name: firstName,
                            avatar: userDict["profilePicture"] as? String ?? userDict["avatar"] as? String
                        )

                        self.currentUser = user
                        self.isLoggedIn = true
                        saveUserToDefaults(user)

                        print("✅ [AUTH] Successfully logged in as \(email) (ID: \(userId))")
                    } else {
                        errorMessage = "Invalid response format"
                        print("❌ [AUTH] Could not parse user data from response")
                    }
                } else {
                    errorMessage = "Invalid response format"
                    print("❌ [AUTH] Could not parse JSON response")
                }
            } else {
                // Handle error response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonResponse["message"] as? String {
                    errorMessage = message
                    print("⚠️ [AUTH] Server error: \(message)")
                } else {
                    errorMessage = "Login failed: HTTP \(httpResponse.statusCode)"
                }
                print("❌ [AUTH] Login error: HTTP \(httpResponse.statusCode)")
            }
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
            print("❌ [AUTH] Login error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Sign Up
    func signup(email: String, firstName: String, lastName: String, password: String) async {
        isLoading = true
        errorMessage = nil

        print("📝 [AUTH] Attempting signup with email: \(email), name: \(firstName) \(lastName)")

        do {
            // Validate inputs
            if email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty {
                errorMessage = "All fields are required"
                isLoading = false
                print("❌ [AUTH] Validation failed: Missing required fields")
                return
            }

            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
                isLoading = false
                print("❌ [AUTH] Validation failed: Password too short")
                return
            }

            // Prepare request
            guard let url = URL(string: "http://localhost:3000/api/auth/register") else {
                errorMessage = "Invalid URL"
                isLoading = false
                print("❌ [AUTH] Invalid API URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "accept")

            // Prepare request body
            let requestBody: [String: String] = [
                "email": email,
                "password": password,
                "confirmPassword": password,
                "firstName": firstName,
                "lastName": lastName
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            print("📤 [AUTH] Sending signup request to \(url.absoluteString)")
            print("📋 [AUTH] Request body: \(requestBody)")

            // Make API call
            let (data, response) = try await URLSession.shared.data(for: request)

            print("📥 [AUTH] Received response from server")

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response"
                isLoading = false
                print("❌ [AUTH] Invalid HTTP response")
                return
            }

            print("📊 [AUTH] HTTP Status Code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Log raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 [AUTH] Raw Response: \(responseString)")
                }

                // Registration successful - navigate to OTP verification
                // Accept any valid response (JSON object, array, or even empty)
                self.pendingVerificationEmail = email
                self.requiresOTPVerification = true
                print("✅ [AUTH] Registration successful, OTP verification required for: \(email)")
            } else {
                // Handle error response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonResponse["message"] as? String {
                    errorMessage = message
                    print("⚠️ [AUTH] Server error: \(message)")
                } else {
                    errorMessage = "Sign up failed: HTTP \(httpResponse.statusCode)"
                }
                print("❌ [AUTH] Sign up error: HTTP \(httpResponse.statusCode)")
            }
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            print("❌ [AUTH] Sign up error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Verify OTP
    func verifyOTP(email: String, otp: String) async {
        isLoading = true
        errorMessage = nil

        print("🔐 [AUTH] Verifying OTP for email: \(email)")

        do {
            guard let url = URL(string: "http://localhost:3000/api/auth/verify-email-otp") else {
                errorMessage = "Invalid URL"
                isLoading = false
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "accept")

            let requestBody: [String: String] = [
                "email": email,
                "otp": otp
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            print("📤 [AUTH] Sending OTP verification request")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response"
                isLoading = false
                return
            }

            print("📊 [AUTH] OTP Verification Status Code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("🔍 [AUTH] OTP Response JSON: \(jsonResponse)")

                    // Try to extract user data from response
                    var userDict: [String: Any]? = nil
                    var userId: String? = nil
                    var firstName: String? = nil

                    // Try different response formats
                    if let dataDict = jsonResponse["data"] as? [String: Any],
                       let userObj = dataDict["user"] as? [String: Any] {
                        userDict = userObj
                    } else if let userObj = jsonResponse["user"] as? [String: Any] {
                        userDict = userObj
                    }

                    if let userDict = userDict {
                        userId = userDict["_id"] as? String
                        firstName = userDict["firstName"] as? String ?? userDict["name"] as? String
                    } else {
                        userId = jsonResponse["_id"] as? String
                        firstName = jsonResponse["firstName"] as? String ?? jsonResponse["name"] as? String
                    }

                    if let userId = userId {
                        let user = User(
                            id: userId,
                            email: email,
                            name: firstName ?? "User",
                            avatar: userDict?["avatar"] as? String ?? userDict?["profilePicture"] as? String
                        )

                        self.currentUser = user
                        self.isLoggedIn = true
                        self.requiresOTPVerification = false
                        self.pendingVerificationEmail = ""
                        saveUserToDefaults(user)

                        print("✅ [AUTH] OTP verified successfully for \(email)")
                    } else {
                        // OTP verified but no user data - just mark as logged in
                        self.isLoggedIn = true
                        self.requiresOTPVerification = false
                        self.pendingVerificationEmail = ""
                        print("✅ [AUTH] OTP verified successfully")
                    }
                }
            } else {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonResponse["message"] as? String {
                    errorMessage = message
                } else {
                    errorMessage = "OTP verification failed"
                }
                print("❌ [AUTH] OTP verification failed: HTTP \(httpResponse.statusCode)")
            }
        } catch {
            errorMessage = "OTP verification failed: \(error.localizedDescription)"
            print("❌ [AUTH] OTP verification error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Resend OTP
    func resendOTP(email: String) async {
        isLoading = true
        errorMessage = nil

        print("📤 [AUTH] Resending OTP to email: \(email)")

        do {
            guard let url = URL(string: "http://localhost:3000/api/auth/resend-otp") else {
                errorMessage = "Invalid URL"
                isLoading = false
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "accept")

            let requestBody: [String: String] = ["email": email]
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response"
                isLoading = false
                return
            }

            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                print("✅ [AUTH] OTP resent successfully to \(email)")
            } else {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = jsonResponse["message"] as? String {
                    errorMessage = message
                } else {
                    errorMessage = "Failed to resend OTP"
                }
            }
        } catch {
            errorMessage = "Failed to resend OTP: \(error.localizedDescription)"
            print("❌ [AUTH] Resend OTP error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Logout
    func logout() {
        currentUser = nil
        isLoggedIn = false
        requiresOTPVerification = false
        pendingVerificationEmail = ""
        removeUserFromDefaults()
        UserDefaults.standard.removeObject(forKey: "authToken")
        print("✅ [AUTH] Successfully logged out")
    }

    // MARK: - UserDefaults Persistence
    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("💾 [AUTH] User saved to UserDefaults")
        }
    }

    private func loadUserFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
            self.isLoggedIn = true
            print("📖 [AUTH] User loaded from UserDefaults: \(user.email)")
        } else {
            print("📖 [AUTH] No user found in UserDefaults")
        }
    }

    private func removeUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        print("🗑️ [AUTH] User removed from UserDefaults")
    }
}
