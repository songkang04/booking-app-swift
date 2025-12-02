//
//  ContentView.swift
//  BookingApp
//
//  Created by Phan Danh Dung on 12/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var isSearching = false
    @State private var searchText = ""

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                AppHeader(isSearching: $isSearching, searchText: $searchText)

                // Content
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeScreen()
                            .onAppear {
                                print("📱 [DEBUG] HomeScreen appeared")
                            }
                    case .search:
                        SearchScreen()
                            .onAppear {
                                print("📱 [DEBUG] SearchScreen appeared")
                            }
                    case .bookings:
                        BookingsListScreen()
                            .onAppear {
                                print("📱 [DEBUG] BookingsListScreen appeared")
                            }
                    case .profile:
                        ProfileScreen()
                            .onAppear {
                                print("📱 [DEBUG] ProfileScreen appeared")
                            }
                    }
                }
                .transition(.opacity)
                .onChange(of: selectedTab) { oldValue, newValue in
                    print("📱 [DEBUG] Tab changed from \(oldValue) to \(newValue)")
                }

                // Bottom Tab Bar
                BottomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(AppColors.background)
        .onAppear {
            print("📱 [DEBUG] ContentView appeared - Initial tab: \(selectedTab)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
