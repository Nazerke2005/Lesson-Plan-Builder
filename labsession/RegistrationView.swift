//
//  RegistrationView.swift
//  labsession
//
//  Created by Assistant on 11.12.2025.
//

import SwiftUI
import SwiftData

struct RegistrationView: View {
    @Environment(\.modelContext) private var modelContext

    // Поля формы
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var school: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    // Состояние
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    // Флаги навигации
    @AppStorage("auth.isOnboarded") private var isOnboarded: Bool = false
    @AppStorage("auth.showLogin") private var showLogin: Bool = false

    // Для совместимости с текущим UI профиля
    @AppStorage("profile.fullName") private var storedFullName: String = ""
    @AppStorage("profile.school") private var storedSchool: String = ""
    @AppStorage("profile.email") private var storedEmail: String = ""
    @AppStorage("profile.role") private var storedRole: String = "Мұғалім"

    var body: some View {
        ZStack {
            // Локальный нежно‑розовый анимированный фон ТОЛЬКО для регистрации
            PinkAnimatedBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Тіркелу")
                            .font(.system(size: 28, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        materialCard {
                            VStack(spacing: 12) {
                                TextField("Аты", text: $firstName)
                                    .textContentType(.givenName)
                                    .submitLabel(.next)

                                TextField("Тегі", text: $lastName)
                                    .textContentType(.familyName)
                                    .submitLabel(.next)

                                TextField("Мектеп", text: $school)
                                    .textContentType(.organizationName)
                                    .submitLabel(.next)

                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .textContentType(.emailAddress)
                                    .submitLabel(.next)

                                SecureField("Құпиясөз (мин. 6 таңба)", text: $password)
                                    .textContentType(.newPassword)
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
                                Text(isSubmitting ? "Сақталуда…" : "Тіркелу")
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
                            showLogin = true
                        } label: {
                            Text("Есептік жазбаңыз бар ма? Кіру")
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
                .navigationTitle("Қош келдіңіз")
                .toolbarBackground(.clear, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            }
        }
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !school.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(email) &&
        password.count >= 6
    }

    private func isValidEmail(_ s: String) -> Bool {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
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

        let user = User(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            school: school.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
        modelContext.insert(user)

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Мәліметтер базасына сақтау қатесі: \(error.localizedDescription)"
            return
        }

        do {
            try KeychainStorage.savePassword(password, for: user.email)
        } catch {
            errorMessage = "Құпиясөзді сақтау қатесі: \(error.localizedDescription)"
            return
        }

        storedFullName = user.fullName
        storedSchool = user.school
        storedEmail = user.email

        isOnboarded = true
    }
}

#Preview {
    RegistrationView()
        .modelContainer(for: [Item.self, Lesson.self, User.self], inMemory: true)
}
