//
//  LessonDetailView.swift
//  labsession
//
//  Created by Nazerke Turganбек on 05.12.2025.
//

import SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var lesson: Lesson

    var body: some View {
        Form {
            Section("Атауы") {
                TextField("Атауы", text: $lesson.title)
            }
            Section("Күні") {
                DatePicker("Күні", selection: $lesson.date, displayedComponents: .date)
            }
            Section("Ескертпелер") {
                TextEditor(text: Binding(
                    get: { lesson.notes ?? "" },
                    set: { lesson.notes = $0.isEmpty ? nil : $0 }
                ))
                .frame(minHeight: 120)
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(lesson)
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Text("Сабақты жою")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Сабақ")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Дайын") {
                    try? modelContext.save()
                    dismiss()
                }
            }
        }
    }
}
