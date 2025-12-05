//
//  Lesson.swift
//  labsession
//
//  Created by Nazerke Turganbek on 05.12.2025.
//

import Foundation
import SwiftData

@Model
final class Lesson {
    var id: UUID
    var title: String
    var date: Date
    var notes: String?

    init(id: UUID = UUID(), title: String, date: Date = .now, notes: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
    }
}
