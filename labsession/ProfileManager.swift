//
//  ProfileManager.swift
//  labsession
//
//  Created by Nazerke Turgанбек on 06.12.2025.
//

import Foundation
import SwiftUI
import Combine

final class ProfileManager: ObservableObject {
    // Store avatar image as PNG/JPEG data in AppStorage
    @AppStorage("profile.avatarImageData") private var storedAvatarData: Data = Data() {
        didSet { objectWillChange.send() }
    }

    // Expose as UIImage/NSImage friendly SwiftUI Image data
    @Published private(set) var avatarImage: Image? = nil
    @Published private(set) var avatarRawData: Data? = nil

    init() {
        loadFromStorage()
    }

    func setAvatar(data: Data?) {
        if let data, !data.isEmpty {
            storedAvatarData = data
        } else {
            storedAvatarData = Data()
        }
        loadFromStorage()
    }

    private func loadFromStorage() {
        if storedAvatarData.isEmpty {
            avatarImage = nil
            avatarRawData = nil
            return
        }
        avatarRawData = storedAvatarData
        #if os(iOS) || os(tvOS) || os(visionOS)
        if let uiImage = UIImage(data: storedAvatarData) {
            avatarImage = Image(uiImage: uiImage)
        } else {
            avatarImage = nil
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: storedAvatarData) {
            avatarImage = Image(nsImage: nsImage)
        } else {
            avatarImage = nil
        }
        #else
        avatarImage = nil
        #endif
    }
}
