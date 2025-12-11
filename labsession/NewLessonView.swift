//
//  NewLessonView.swift
//  labsession
//
//  Created by Nazerke Тургaнбек on 05.12.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct NewLessonView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var notes: String = ""

    // Новое: вложения
    @State private var attachments: [Attachment] = []
    @State private var showFileImporter: Bool = false
    @State private var importError: String?

    // onSave теперь с вложениями
    var onSave: (String, Date, String?, [Attachment]) -> Void

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    materialCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Атауы")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            TextField("Мысалы: Фотосинтезге кіріспе", text: $title)
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.done)
                        }
                    }

                    materialCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Күні")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("Күні", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }

                    materialCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ескертпелер (қалауыңызша)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $notes)
                                .frame(minHeight: 140)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.primary.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }

                    // Вложения
                    materialCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Қосылған құжаттар")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button {
                                    showFileImporter = true
                                } label: {
                                    Label("Құжат қосу", systemImage: "paperclip")
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            if let importError {
                                Text(importError)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }

                            if attachments.isEmpty {
                                Text("Құжаттар әлі қосылмады.")
                                    .foregroundStyle(.secondary)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(attachments) { att in
                                        HStack(spacing: 10) {
                                            Image(systemName: iconName(for: att))
                                                .foregroundStyle(.secondary)
                                            Text(att.filename)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            Spacer()
                                            Button {
                                                // Удаление вложения из списка
                                                if let idx = attachments.firstIndex(where: { $0.id == att.id }) {
                                                    attachments.remove(at: idx)
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(.red)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        guard !isSaveDisabled else { return }
                        onSave(
                            title.trimmingCharacters(in: .whitespacesAndNewlines),
                            date,
                            notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes,
                            attachments
                        )
                        dismiss()
                    } label: {
                        Text("Сақтау")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.blue, .purple, .pink],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .opacity(isSaveDisabled ? 0.6 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaveDisabled)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("Жаңа сабақ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") { dismiss() }
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: allowedTypes(),
                allowsMultipleSelection: true
            ) { result in
                handleImportResult(result)
            }
        }
    }

    // MARK: - Reusable material card (styled like on the main page)
    @ViewBuilder
    private func materialCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Attachments helpers

    private func allowedTypes() -> [UTType] {
        var types: [UTType] = [.pdf]
        if let doc = UTType(filenameExtension: "doc") {
            types.append(doc)
        }
        if let docx = UTType(filenameExtension: "docx") {
            types.append(docx)
        }
        return types
    }

    private func iconName(for attachment: Attachment) -> String {
        if attachment.utType == .pdf {
            return "doc.richtext" // или "doc.fill" — на вкус
        }
        if attachment.utiIdentifier.contains("word") || attachment.utiIdentifier.contains("doc") {
            return "doc.text"
        }
        return "doc"
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importError = "Импорт қатесі: \(error.localizedDescription)"
        case .success(let urls):
            importError = nil
            Task {
                for url in urls {
                    await importFile(url: url)
                }
            }
        }
    }

    @MainActor
    private func importFile(url: URL) async {
        // Копируем выбранный файл в Documents приложения
        do {
            let fm = FileManager.default
            let docs = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let targetURL = docs.appendingPathComponent(url.lastPathComponent)

            // Если файл с таким именем уже есть — добавим суффикс
            let finalURL = uniqueURL(for: targetURL)

            // Доступ к security-scoped, если требуется
            var didStartAccess = false
            if url.startAccessingSecurityScopedResource() {
                didStartAccess = true
            }
            defer {
                if didStartAccess { url.stopAccessingSecurityScopedResource() }
            }

            // Копируем
            if fm.fileExists(atPath: finalURL.path) == false {
                try fm.copyItem(at: url, to: finalURL)
            }

            // Создаем bookmarkData
            #if os(macOS)
            let bookmark = try finalURL.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
            #else
            let bookmark = try finalURL.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
            #endif

            // Определяем UTI
            let uti = (try? finalURL.resourceValues(forKeys: [.contentTypeKey]).contentType?.identifier)
                ?? UTType(filenameExtension: finalURL.pathExtension)?.identifier
                ?? "public.data"

            let att = Attachment(filename: finalURL.lastPathComponent, utiIdentifier: uti, bookmarkData: bookmark)

            // Добавляем в список, избегая дубликатов по имени
            if !attachments.contains(where: { $0.filename == att.filename }) {
                attachments.append(att)
            }
        } catch {
            importError = "Құжатты көшіру қатесі: \(error.localizedDescription)"
        }
    }

    private func uniqueURL(for url: URL) -> URL {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            return url
        }
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let dir = url.deletingLastPathComponent()

        var idx = 2
        while true {
            let candidate = dir.appendingPathComponent("\(base) (\(idx))").appendingPathExtension(ext)
            if !fm.fileExists(atPath: candidate.path) {
                return candidate
            }
            idx += 1
        }
    }
}

