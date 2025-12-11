//
//  Lesson.swift
//  labsession
//
//  Created by Nazerke Turganбек on 05.12.2025.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers

@Model
final class Lesson {
    var id: UUID
    var title: String
    var date: Date
    var notes: String?

    // Новые вложения
    var attachments: [Attachment]

    init(id: UUID = UUID(), title: String, date: Date = .now, notes: String? = nil, attachments: [Attachment] = []) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
        self.attachments = attachments
    }
}

// MARK: - Attachment model

@Model
final class Attachment: Identifiable {
    var id: UUID
    var filename: String
    // UTI идентификатор (Uniform Type Identifier), например "com.adobe.pdf" или "org.openxmlformats.wordprocessingml.document"
    var utiIdentifier: String
    // Security-scoped bookmark для локального URL файла
    var bookmarkData: Data

    init(id: UUID = UUID(), filename: String, utiIdentifier: String, bookmarkData: Data) {
        self.id = id
        self.filename = filename
        self.utiIdentifier = utiIdentifier
        self.bookmarkData = bookmarkData
    }

    // Вспомогательный метод: восстановить URL из bookmarkData
    func resolveURL() -> URL? {
        var isStale = false
        do {
            #if os(macOS)
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            #else
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            #endif
            return url
        } catch {
            return nil
        }
    }

    // Удобный UTType
    var utType: UTType? {
        UTType(utiIdentifier)
    }
}
