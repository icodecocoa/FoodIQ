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

extension NutritionReport {
    static func computeQualityScore(calories: Int, protein: Int, carbs: Int, fat: Int, sodium: Int) -> Double {
        var score: Double = 5.0

        // Check protein balance (should be >10% of calories ideally)
        let proteinCalories = protein * 4
        if Double(proteinCalories) / Double(max(calories, 1)) < 0.1 {
            score -= 1.0
        }

        // High fat penalty
        let fatCalories = fat * 9
        if Double(fatCalories) / Double(max(calories, 1)) > 0.35 {
            score -= 1.0
        }

        // High sodium penalty (>600mg / 100g is high)
        if sodium > 600 {
            score -= 1.0
        }

        // Too many carbs (especially if protein is low)
        if carbs > 50 && protein < 5 {
            score -= 1.0
        }

        return max(0.0, min(5.0, score))
    }
}
