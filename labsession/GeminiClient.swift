// GeminiClient.swift
import Foundation

struct GeminiClient {
    struct GenerateContentRequest: Codable {
        struct Content: Codable {
            struct Part: Codable {
                let text: String
            }
            let role: String?
            let parts: [Part]
        }
        let contents: [Content]
        let generationConfig: GenerationConfig?
    }

    struct GenerationConfig: Codable {
        let temperature: Double?
        let maxOutputTokens: Int?
    }

    struct GenerateContentResponse: Codable {
        struct Candidate: Codable {
            struct Content: Codable {
                struct Part: Codable {
                    let text: String?
                }
                let parts: [Part]
            }
            let content: Content
            let finishReason: String?
            let index: Int?
        }
        let candidates: [Candidate]?
    }

    enum GeminiError: Error {
        case missingAPIKey
        case badResponse
        case httpError(Int, String)
        case decodingFailed
        case emptyResult
    }

    let apiKey: String
    let model: String
    let baseURL: URL

    init(model: String = "gemini-1.5-flash") throws {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiError.missingAPIKey
        }
        self.apiKey = key
        self.model = model
        self.baseURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
    }

    func generateAnswer(prompt: String) async throws -> String {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GenerateContentRequest(
            contents: [
                .init(role: "user", parts: [.init(text: "Сен қазақ тілінде сабақ жоспарларын құруға көмектесетін көмекшісің.")]),
                .init(role: "user", parts: [.init(text: prompt)])
            ],
            generationConfig: .init(temperature: 0.7, maxOutputTokens: 800)
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw GeminiError.badResponse }
        guard (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw GeminiError.httpError(http.statusCode, text)
        }

        let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: data)
        guard let first = decoded.candidates?.first else { throw GeminiError.emptyResult }

        // Concatenate all text parts if multiple
        let text = first.content.parts.compactMap { $0.text }.joined(separator: "\n")
        guard !text.isEmpty else { throw GeminiError.decodingFailed }
        return text
    }
}
