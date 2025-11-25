//
//  User.swift
//  BookingApp
//
//  Created by Tien Nguyen on 25/11/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let avatar: String?
    
    init(id: String = UUID().uuidString, email: String, name: String, avatar: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.avatar = avatar
    }
}
