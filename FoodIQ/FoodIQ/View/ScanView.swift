//
//  ScanView.swift
//  FoodIQ
//
//  Created by Drashti Lakhani on 9/12/25.
//

import SwiftUI

struct ScanView: View {
    @State private var scannedCode: String?
    @State private var report: NutritionReport?
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            if let report = report {
                VStack {
                    Text("Calories: \(report.calories)")
                    Text("Protein: \(report.protein) g")
                    Text("Carbs: \(report.carbs) g")
                    Text("Fat: \(report.fat) g")
                    Text("Sodium: \(report.sodium) mg")
                    Text("⭐ Quality Score: \(String(format: "%.1f", report.qualityScore))/5")
                                .font(.headline)
                                .foregroundColor(report.qualityScore >= 4 ? .green : .orange)
                }
                .padding()
                
                Button("Save to FoodIQ") {
                    saveFoodEntry(report: report)
                }
            } else if let code = scannedCode {
                ProgressView("Fetching nutrition for \(code)...")
                    .task {
                        do {
                            let service = BarcodeNutritionService()
                            report = try await service.fetchNutrition(for: code)
                        } catch {
                            print("Error fetching: \(error)")
                            scannedCode = nil
                        }
                    }
            } else {
                BarcodeScannerView(scannedCode: $scannedCode)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func saveFoodEntry(report: NutritionReport) {
        let entry = FoodEntry(context: viewContext)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.calories = report.calories
        entry.protein = report.protein
        entry.carbs = report.carbs
        entry.fat = report.fat
        entry.sodium = report.sodium
        entry.qualityScore = Int16(report.qualityScore)
        entry.notes = report.notes
        
        try? viewContext.save()
    }
}
