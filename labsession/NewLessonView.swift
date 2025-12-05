//
//  NewLessonView.swift
//  labsession
//
//  Created by Nazerke Turgанбек on 05.12.2025.
//

import SwiftUI

struct NewLessonView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var notes: String = ""

    var onSave: (String, Date, String?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Атауы") {
                    TextField("Мысалы: Фотосинтезге кіріспе", text: $title)
                }
                Section("Күні") {
                    DatePicker("Күні", selection: $date, displayedComponents: .date)
                }
                Section("Ескертпелер (қалауыңызша)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Жаңа сабақ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сақтау") {
                        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        onSave(title, date, notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                }
            }
        }
    }
}
