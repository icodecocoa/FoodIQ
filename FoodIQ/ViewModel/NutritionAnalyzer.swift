import Foundation
import UIKit
import FirebaseAI

struct NutritionReport: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let sodium: Double
    let qualityScore: Double
    let notes: String
}

class NutritionAnalyzer {
    let ai: FirebaseAI
    var model: GenerativeModel
    
    init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }

    func analyze(image: UIImage, completion: @escaping (Result<NutritionReport, Error>) -> Void) {
        Task {
            do {
                let response = try await model.generateContent([image, "Analyze this food image. Return JSON only with calories, protein, carbs, fat, sodium, qualityScore, notes."])
                
                let rawResponse = response.text ?? ""
                
                if let jsonString = cleanJSON(rawResponse), let data = jsonString.data(using: .utf8) {
                    let decoded = try JSONDecoder().decode(NutritionReport.self, from: data)
                    completion(.success(decoded))
                } else {
                    completion(.failure(NSError(domain: "ParseError", code: -1)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func cleanJSON(_ text: String) -> String? {
        // Try to find content between first { and last }
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else { return nil }
        return String(text[startIndex...endIndex])
    }
}
