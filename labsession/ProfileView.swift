//
//  ProfileView.swift
//  labsession
//
//  Created by Nazerke Тургaнбек on 06.12.2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileManager: ProfileManager

    // Persisted user data
    @AppStorage("profile.fullName") private var fullName: String = "Нәзерке Турғанбек"
    @AppStorage("profile.role") private var role: String = "Мұғалім"
    @AppStorage("profile.school") private var school: String = "№12 мектеп-лицей"
    @AppStorage("profile.email") private var email: String = "user@example.com"

    // Settings
    @AppStorage("app.theme") private var theme: Int = 0
    @AppStorage("app.language") private var language: String = "kk"

    @State private var isEditingProfile: Bool = false
    @AppStorage("profile.notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("profile.biometricEnabled") private var biometricEnabled: Bool = false
    @State private var showSignOutConfirm: Bool = false

    // Auth flow flags
    @AppStorage("auth.isOnboarded") private var isOnboarded: Bool = false
    @AppStorage("auth.showLogin") private var showLogin: Bool = false

    // For PhotosPicker
    @State private var avatarPickerItem: PhotosPickerItem? = nil
    @State private var isImporting: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard

                    VStack(spacing: 12) {
                        GradientButton(title: "Профильді өңдеу", systemImage: "pencil", gradient: [.blue, .purple, .pink]) {
                            isEditingProfile = true
                        }
                        GradientButton(title: "Хабарландырулар", systemImage: "bell.badge", gradient: [.blue, .purple, .pink]) {
                            notificationsEnabled.toggle()
                        }
                        GradientButton(title: "Қауіпсіздік", systemImage: "lock.shield", gradient: [.blue, .purple, .pink]) {
                            biometricEnabled.toggle()
                        }
                    }

                    materialCard {
                        VStack(alignment: .leading, spacing: 10) {
                            labeledRow("Аты-жөні", value: fullName)
                            labeledRow("Рөлі", value: role)
                            labeledRow("Мектеп", value: school)
                            labeledRow("Email", value: email)
                        }
                    }

                    materialCard {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "paintbrush")
                                    .foregroundStyle(.secondary)
                                Text("Тақырып")
                                Spacer()
                                Picker("", selection: $theme) {
                                    Text("Жүйелік").tag(0)
                                    Text("Жарық").tag(1)
                                    Text("Қараңғы").tag(2)
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 280)
                            }

                            Divider().background(.secondary.opacity(0.2))

                            HStack {
                                Image(systemName: "character.book.closed")
                                    .foregroundStyle(.secondary)
                                Text("Тіл")
                                Spacer()
                                Picker("", selection: $language) {
                                    Text("Қазақша").tag("kk")
                                    Text("Русский").tag("ru")
                                    Text("English").tag("en")
                                }
                                .pickerStyle(.menu)
                            }

                            Divider().background(.secondary.opacity(0.2))

                            Toggle(isOn: $notificationsEnabled) {
                                HStack {
                                    Image(systemName: "bell")
                                        .foregroundStyle(.secondary)
                                    Text("Хабарландырулар")
                                }
                            }

                            Toggle(isOn: $biometricEnabled) {
                                HStack {
                                    Image(systemName: "faceid")
                                        .foregroundStyle(.secondary)
                                    Text("Биометриямен қорғау")
                                }
                            }
                        }
                    }

                    materialCard {
                        VStack(spacing: 12) {
                            linkRow(title: "Көмек және кері байланыс", systemImage: "questionmark.circle") {
                            }
                            Divider().background(.secondary.opacity(0.2))
                            linkRow(title: "Құпиялылық саясаты", systemImage: "hand.raised") {
                            }
                            Divider().background(.secondary.opacity(0.2))
                            linkRow(title: "Қолданба туралы", systemImage: "info.circle") {
                            }
                        }
                    }

                    DestructiveMaterialButton(title: "Шығу", systemImage: "rectangle.portrait.and.arrow.right") {
                        showSignOutConfirm = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.clear.ignoresSafeArea())
            .navigationTitle("Профиль")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Жабу") { dismiss() }
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .sheet(isPresented: $isEditingProfile) {
                EditProfileSheet(
                    fullName: $fullName,
                    role: $role,
                    school: $school,
                    email: $email
                )
                .presentationDetents([.medium, .large])
            }
            .alert("Шығу", isPresented: $showSignOutConfirm) {
                Button("Болдырмау", role: .cancel) {}
                Button("Шығу", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Ақпаратыңыз сақталады. Шығуды растаңыз.")
            }
            .onChange(of: avatarPickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        profileManager.setAvatar(data: data)
                    }
                }
            }
        }
    }
}

// MARK: - Helpers inside ProfileView

private extension ProfileView {
    var headerCard: some View {
        materialCard {
            HStack(spacing: 14) {
                ZStack(alignment: .bottomTrailing) {
                    avatarDisplay
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)

                    PhotosPicker(selection: $avatarPickerItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(.blue, in: Circle())
                            .overlay(
                                Circle().stroke(.white, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .offset(x: 2, y: 2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(fullName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !school.isEmpty {
                        Text(school)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if !email.isEmpty {
                        Text(email)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    var avatarDisplay: some View {
        if let image = profileManager.avatarImage {
            image
                .resizable()
                .scaledToFill()
        } else {
            avatarView(initials: initials(from: fullName))
        }
    }

    @ViewBuilder
    func materialCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    func labeledRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
        .font(.system(size: 16))
    }

    @ViewBuilder
    func linkRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    func avatarView(initials: String) -> some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(initials)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }

    func initials(from name: String) -> String {
        let parts = name
            .split(whereSeparator: { $0.isWhitespace })
            .map { String($0) }
        let first = parts.first?.first.map { String($0) } ?? ""
        let second = parts.dropFirst().first?.first.map { String($0) } ?? ""
        return (first + second).uppercased()
    }

    func signOut() {
        isOnboarded = false
        showLogin = false
        KeychainStorage.deletePassword(for: email)
        fullName = ""
        role = "Мұғалім"
        school = ""
        email = ""
        profileManager.setAvatar(data: nil)
        dismiss()
    }
}

// Simple edit sheet
private struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var fullName: String
    @Binding var role: String
    @Binding var school: String
    @Binding var email: String

    var body: some View {
        NavigationStack {
            Form {
                Section("Аты-жөні") {
                    TextField("Аты-жөні", text: $fullName)
                }
                Section("Рөлі") {
                    TextField("Рөлі", text: $role)
                }
                Section("Мектеп") {
                    TextField("Мектеп", text: $school)
                }
                Section("Email") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle("Профильді өңдеу")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Болдырмау") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сақтау") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileManager())
}
