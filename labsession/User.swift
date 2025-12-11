//
//  User.swift
//  labsession
//
//  Created by Assistant on 11.12.2025.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var firstName: String
    var lastName: String
    var school: String
    var email: String
    var createdAt: Date

    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         school: String,
         email: String,
         createdAt: Date = .now) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.school = school
        self.email = email
        self.createdAt = createdAt
    }

    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }
}
