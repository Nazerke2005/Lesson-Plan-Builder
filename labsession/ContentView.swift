//
//  ContentView.swift
//  labsession
//
//  Created by Nazerke Тургaнбек on 05.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var profileManager: ProfileManager

    // Загружаем уроки, сортируем по дате по убыванию
    @Query(sort: \Lesson.date, order: .reverse)
    private var lessons: [Lesson]

    @State private var searchText: String = ""
    @State private var showingNewLesson: Bool = false
    @State private var aiSheetPresented: Bool = false

    // Состояние полноэкранного меню
    @State private var isMenuOpen: Bool = false

    // Profile sheet
    @State private var showProfileSheet: Bool = false

    // Имя пользователя из профиля
    @AppStorage("profile.fullName") private var fullName: String = "Нәзерке Турғанбек"

    private var filteredLessons: [Lesson] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return lessons
        }
        return lessons.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchField
                    addLessonButton
                    lessonList
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
            .navigationTitle("")
            #if os(macOS)
            .navigationTitle("")
            #else
            .toolbarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .automatic) {
                    burgerButton
                }
                #else
                ToolbarItem(placement: .topBarTrailing) {
                    burgerButton
                }
                #endif
            }
            .sheet(isPresented: $showingNewLesson) {
                NewLessonView { title, date, notes in
                    let new = Lesson(title: title, date: date, notes: notes)
                    modelContext.insert(new)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $aiSheetPresented) {
                AIAssistView { prompt in
                    do {
                        return try await OpenAIClient().generateAnswer(prompt: prompt)
                    } catch {
                        return "Қате: \(error.localizedDescription)"
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
                    .presentationDetents([.large])
            }
            // Полноэкранное меню
            .fullScreenCover(isPresented: $isMenuOpen) {
                FullscreenMenuView(
                    isPresented: $isMenuOpen,
                    openAISheet: { aiSheetPresented = true },
                    openNewLesson: { showingNewLesson = true },
                    openProfile: { showProfileSheet = true }
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - Toolbar button

    private var burgerButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) {
                isMenuOpen = true
            }
        } label: {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 12))
                        .foregroundStyle(.primary.opacity(0.8))
                )
                .accessibilityLabel("Бургер мәзірі")
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                // Открываем профиль по нажатию на аватар
                showProfileSheet = true
            } label: {
                avatarOrPlaceholder
            }
            .buttonStyle(.plain)

            // Приветствие и имя пользователя
            VStack(alignment: .leading, spacing: 2) {
                Text("Сәлем,")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(firstName(from: fullName))!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(height: 56, alignment: .leading)
    }

    @ViewBuilder
    private var avatarOrPlaceholder: some View {
        if let image = profileManager.avatarImage {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40) // увеличенный аватар
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
                .accessibilityLabel("Профиль")
        } else {
            // Фолбэк до установки аватарки
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "sparkles")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                )
                .accessibilityLabel("Профиль")
        }
    }

    private func firstName(from fullName: String) -> String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return String(localized: "guest") } // локализуемое "Гость"/"Қонақ"/"Guest"
        let parts = trimmed.split(separator: " ")
        if let first = parts.first {
            return String(first)
        }
        return trimmed
    }

    private var searchField: some View {
        TextField("Іздеу", text: $searchText)
            .textFieldStyle(.plain)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var addLessonButton: some View {
        Button {
            showingNewLesson = true
        } label: {
            Text("Жаңа сабақ")
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
        }
        .buttonStyle(.plain)
    }

    private var lessonList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(filteredLessons) { lesson in
                NavigationLink(value: lesson) {
                    lessonRow(lesson)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationDestination(for: Lesson.self) { lesson in
            LessonDetailView(lesson: lesson)
        }
    }

    private func lessonRow(_ lesson: Lesson) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            Text(lesson.date.formatted(date: .long, time: .omitted))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Fullscreen menu view

private struct FullscreenMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool

    var openAISheet: () -> Void
    var openNewLesson: () -> Void
    var openProfile: () -> Void

    @State private var appear: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.secondary.opacity(0.08),
                    Color.secondary.opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button {
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer(minLength: 0)

                VStack(spacing: 16) {
                    GradientButton(title: "AI көмекші", systemImage: "sparkles", gradient: [.blue, .purple, .pink]) {
                        openAISheet()
                        close()
                    }

                    GradientButton(title: "Жаңа сабақ", systemImage: "plus", gradient: [.blue, .purple, .pink]) {
                        openNewLesson()
                        close()
                    }

                    GradientButton(title: "Профиль", systemImage: "person.crop.circle", gradient: [.blue, .purple, .pink]) {
                        openProfile()
                        close()
                    }

                    MaterialButton(title: "Барлық сабақтар", systemImage: "list.bullet", enabled: false) {
                    }

                    Divider().background(.secondary.opacity(0.3))

                    DestructiveMaterialButton(title: "Шығу", systemImage: "rectangle.portrait.and.arrow.right") {
                        close()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 20)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)
                .animation(.easeOut(duration: 0.28), value: appear)

                Spacer(minLength: 60)
            }
        }
        .onAppear { appear = true }
    }

    private func close() {
        withAnimation(.easeInOut(duration: 0.22)) {
            appear = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            isPresented = false
        }
    }
}

// Қарапайым AI көмекші панелі (sheet) — жаңартылған стиль
private struct AIAssistView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var prompt: String = ""
    @State private var isLoading: Bool = false
    @State private var answer: String = ""

    var generate: (String) async -> String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Prompt input — material card
                    materialCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Сұрағыңыз")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField(
                                "Мысалы: 7-сынып биология сабағына жоспар құрып бер",
                                text: $prompt,
                                axis: .vertical
                            )
                            .lineLimit(3, reservesSpace: true)
                            .textFieldStyle(.roundedBorder)
                        }
                    }

                    // Generate button styled like GradientButton
                    Button {
                        Task {
                            guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            isLoading = true
                            let result = await generate(prompt)
                            answer = result
                            isLoading = false
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            }
                            Text(isLoading ? "Генерация…" : "Жасау")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.blue, .purple, .pink],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)

                    // Answer display — material card
                    materialCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Жауап")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if answer.isEmpty {
                                Text("Жауап осында пайда болады.")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(answer)
                                    .foregroundStyle(.primary)
                                    .textSelection(.enabled)
                            }
                        }
                    }
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
            .navigationTitle("AI көмекші")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Жабу") { dismiss() }
                }
            }
        }
    }

    // Material card helper (match main page)
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

#Preview {
    ContentView()
        .environmentObject(ProfileManager())
        .modelContainer(for: [Item.self, Lesson.self], inMemory: true)
}
