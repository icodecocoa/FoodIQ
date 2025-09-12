//
//  BarcodeNutritionService.swift
//  FoodIQ
//
//  Created by Drashti Lakhani on 9/12/25.
//

import Foundation

class BarcodeNutritionService {
    @Published var showError: Bool = false

    func fetchNutrition(for barcode: String) async throws -> NutritionReport {
        let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let product = json?["product"] as? [String: Any],
              let nutriments = product["nutriments"] as? [String: Any] else {
            throw NSError(domain: "FoodIQ", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        return NutritionReport(
            calories: (nutriments["energy-kcal_100g"] as? Double) ?? 0.0,
            protein: (nutriments["proteins_100g"] as? Double) ?? 0.0,
            carbs: (nutriments["carbohydrates_100g"] as? Double) ?? 0.0,
            fat: (nutriments["fat_100g"] as? Double) ?? 0.0,
            sodium: (nutriments["sodium_100g"] as? Double) ?? 0.0,
            qualityScore: NutritionReport.computeQualityScore(
                calories: Int((nutriments["energy-kcal_100g"] as? Double) ?? 0),
                protein: Int((nutriments["proteins_100g"] as? Double) ?? 0),
                carbs: Int((nutriments["carbohydrates_100g"] as? Double) ?? 0),
                fat: Int((nutriments["fat_100g"] as? Double) ?? 0),
                sodium: Int((nutriments["sodium_100g"] as? Double) ?? 0)), // Can compute a score based on macros
            notes: product["product_name"] as? String ?? "Packaged food item"
        )
    }
}
