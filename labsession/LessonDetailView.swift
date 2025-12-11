//
//  LessonDetailView.swift
//  labsession
//
//  Created by Nazerke Тургaнбек on 05.12.2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct LessonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State var lesson: Lesson

    // Нежные розовые оттенки фона
    private let softPink1 = Color(red: 1.0, green: 0.92, blue: 0.96)   // #FFEAF5
    private let softPink2 = Color(red: 1.0, green: 0.95, blue: 0.98)   // #FFF2FA
    private let softPinkAccent = Color(red: 0.98, green: 0.78, blue: 0.90) // #FBC7E6 (очень мягкий)

    // Для шаринга/открытия
    @State private var shareItem: ShareItem?

    var body: some View {
        ZStack {
            // Эстетичный нежно‑розовый фон
            LinearGradient(
                colors: [
                    softPink2.opacity(0.85),
                    softPink1.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                // Едва заметные «пятна» для глубины (soft glow)
                ZStack {
                    Circle()
                        .fill(softPinkAccent.opacity(0.18))
                        .blur(radius: 60)
                        .frame(width: 220, height: 220)
                        .offset(x: -120, y: -180)

                    Circle()
                        .fill(softPinkAccent.opacity(0.14))
                        .blur(radius: 70)
                        .frame(width: 260, height: 260)
                        .offset(x: 130, y: 240)
                }
            )
            .ignoresSafeArea()

            // Контент формы поверх
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

                // Вложения
                if !lesson.attachments.isEmpty {
                    Section("Құжаттар") {
                        ForEach(lesson.attachments) { att in
                            HStack {
                                Image(systemName: iconName(for: att))
                                    .foregroundStyle(.secondary)
                                Text(att.filename)
                                    .lineLimit(1)
                                Spacer()
                                Button {
                                    openAttachment(att)
                                } label: {
                                    Image(systemName: "arrow.down.circle")
                                }
                                .buttonStyle(.plain)
                                .help("Ашу/жүктеу")
                            }
                        }
                    }
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
            // Скрываем системный фон формы, чтобы был виден наш нежный фон
            .scrollContentBackground(.hidden)
            .background(Color.clear)
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
        // Прозрачный фон навбара
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        // ShareSheet (iOS) / macOS Share
        .sheet(item: $shareItem) { item in
            ShareView(items: [item.url])
        }
    }

    private func iconName(for attachment: Attachment) -> String {
        if attachment.utType == .pdf {
            return "doc.richtext"
        }
        if attachment.utiIdentifier.contains("word") || attachment.utiIdentifier.contains("doc") {
            return "doc.text"
        }
        return "doc"
    }

    private func openAttachment(_ attachment: Attachment) {
        guard let url = attachment.resolveURL() else { return }
        #if os(iOS) || os(tvOS) || os(visionOS)
        // Для iOS — откроем системный Share Sheet, пользователь сможет «скачать/сохранить/открыть в…»
        shareItem = ShareItem(url: url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}

// MARK: - Simple Share helpers (iOS)

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

