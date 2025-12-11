// OpenAIClient.swift
import Foundation

struct OpenAIClient {
    struct ChatMessage: Codable {
        let role: String
        let content: String
    }

    struct ChatRequest: Codable {
        let model: String
        let messages: [ChatMessage]
        let temperature: Double?
        let max_tokens: Int?
    }

    struct ChatResponse: Codable {
        struct Choice: Codable {
            struct Message: Codable {
                let role: String
                let content: String
            }
            let index: Int
            let message: Message
            let finish_reason: String?
        }
        let id: String
        let object: String
        let created: Int
        let model: String
        let choices: [Choice]
    }

    enum OpenAIError: Error {
        case missingAPIKey
        case badResponse
        case decodingFailed
        case httpError(Int, String)
    }

    let apiKey: String
    let baseURL: URL

    init() throws {
        // Info.plist-тен API кілтті оқимыз
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw OpenAIError.missingAPIKey
        }
        self.apiKey = key
        self.baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    }

    func generateAnswer(prompt: String, model: String = "gpt-4o-mini") async throws -> String {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: "You are a helpful teaching assistant that helps create lesson plans in Kazakh."),
                .init(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 800
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw OpenAIError.badResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw OpenAIError.httpError(http.statusCode, text)
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        if let content = decoded.choices.first?.message.content, !content.isEmpty {
            return content
        } else {
            throw OpenAIError.decodingFailed
        }
    }
}
