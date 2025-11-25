//
//  BookingAppApp.swift
//  BookingApp
//
//  Created by Tien Nguyen on 18/11/25.
//

import SwiftUI

@main
struct BookingAppApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
