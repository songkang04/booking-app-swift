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
                    case .search:
                        SearchScreen()
                    case .profile:
                        ProfileScreen()
                    }
                }
                .transition(.opacity)
                
                // Bottom Tab Bar
                BottomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(AppColors.background)
    }
}

#Preview {
    ContentView()
}
