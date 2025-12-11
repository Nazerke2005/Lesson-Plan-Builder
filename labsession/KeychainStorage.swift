//
//  KeychainStorage.swift
//  labsession
//
//  Created by Assistant on 11.12.2025.
//

import Foundation
import Security

enum KeychainStorage {
    static func savePassword(_ password: String, for email: String) throws {
        let service = Bundle.main.bundleIdentifier ?? "labsession"
        let account = email
        let passwordData = Data(password.utf8)

        // Удаляем старую запись, если была
        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(queryDelete as CFDictionary)

        // Добавляем новую
        let queryAdd: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(queryAdd as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func loadPassword(for email: String) throws -> String? {
        let service = Bundle.main.bundleIdentifier ?? "labsession"
        let account = email

        let queryGet: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(queryGet as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        return String(data: data, encoding: .utf8)
    }

    static func deletePassword(for email: String) {
        let service = Bundle.main.bundleIdentifier ?? "labsession"
        let account = email
        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(queryDelete as CFDictionary)
    }
}
