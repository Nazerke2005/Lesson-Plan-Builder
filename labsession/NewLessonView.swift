//
//  NewLessonView.swift
//  labsession
//
//  Created by Nazerke Тurgанбек on 05.12.2025.
//

import SwiftUI

struct NewLessonView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var notes: String = ""

    var onSave: (String, Date, String?) -> Void

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Атауы
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

                    // Күні
                    materialCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Күні")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("Күні", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }

                    // Ескертпелер
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

                    // Save button like prominent action
                    Button {
                        guard !isSaveDisabled else { return }
                        onSave(title.trimmingCharacters(in: .whitespacesAndNewlines),
                               date,
                               notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes)
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
            .background(
                LinearGradient(
                    colors: [
                        Color.secondary.opacity(0.08),
                        Color.secondary.opacity(0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Жаңа сабақ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") { dismiss() }
                }
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
}
