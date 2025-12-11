//
//  LoginView.swift
//  labsession
//
//  Created by Assistant on 11.12.2025.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    // Навигационные флаги
    @AppStorage("auth.isOnboarded") private var isOnboarded: Bool = false
    @AppStorage("auth.showLogin") private var showLogin: Bool = true

    // Для совместимости с текущим UI
    @AppStorage("profile.fullName") private var storedFullName: String = ""
    @AppStorage("profile.school") private var storedSchool: String = ""
    @AppStorage("profile.email") private var storedEmail: String = ""
    @AppStorage("profile.role") private var storedRole: String = "Мұғалім"

    // Пользователи для проверки email
    @Query private var users: [User]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Кіру")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    materialCard {
                        VStack(spacing: 12) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.username)
                                .submitLabel(.next)

                            SecureField("Құпиясөз", text: $password)
                                .textContentType(.password)
                                .submitLabel(.done)
                        }
                    }

                    if let msg = errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            if isSubmitting { ProgressView().tint(.white) }
                            Text(isSubmitting ? "Тексерілуде…" : "Кіру")
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
                        .opacity(isFormValid ? 1 : 0.6)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isFormValid || isSubmitting)

                    Button {
                        showLogin = false
                    } label: {
                        Text("Жаңа қолданушысыз ба? Тіркелу")
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("Қайта оралу")
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        isValidEmail(email) && password.count >= 6
    }

    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".")
    }

    @ViewBuilder
    private func materialCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @MainActor
    private func submit() async {
        guard isFormValid else { return }
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard let user = users.first(where: { $0.email.lowercased() == normalizedEmail }) else {
            errorMessage = "Пайдаланушы табылмады."
            return
        }

        do {
            guard let storedPassword = try KeychainStorage.loadPassword(for: normalizedEmail) else {
                errorMessage = "Құпиясөз табылмады."
                return
            }
            guard storedPassword == password else {
                errorMessage = "Құпиясөз қате."
                return
            }
        } catch {
            errorMessage = "Құпиясөзді тексеру қатесі: \(error.localizedDescription)"
            return
        }

        storedFullName = user.fullName
        storedSchool = user.school
        storedEmail = user.email

        isOnboarded = true
    }
}

#Preview {
    LoginView()
        .modelContainer(for: [Item.self, Lesson.self, User.self], inMemory: true)
}
