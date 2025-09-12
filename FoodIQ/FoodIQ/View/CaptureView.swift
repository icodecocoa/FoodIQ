import SwiftUI

struct CaptureView: View {
    @State private var showScanner = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var report: NutritionReport?
    @State private var isAnalyzing = false
    @Environment(\.managedObjectContext) private var viewContext

    let analyzer = NutritionAnalyzer()

    var body: some View {
        VStack {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            if let report {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories: \(report.calories)")
                    Text("Protein: \(report.protein) g")
                    Text("Carbs: \(report.carbs) g")
                    Text("Fat: \(report.fat) g")
                    Text("Sodium: \(report.sodium) mg")
                    Text("Quality Score: \(report.qualityScore)/100")
                    Text("Notes: \(report.notes)")
                }
                .padding()
            }
            
            if isAnalyzing {
                ProgressView("Analyzing...")
            }
            
            HStack {
                Button("Select Photo") {
                    showingImagePicker = true
                }
                .padding()
                
                Button(action: {
                    showScanner = true
                }) {
                    Label("Scan Barcode", systemImage: "barcode.viewfinder")
                }
                .sheet(isPresented: $showScanner) {
                    ScanView()
                }
                
                if selectedImage != nil {
                    Button("Analyze") {
                        analyzeFood()
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    func analyzeFood() {
        guard let selectedImage else { return }
        isAnalyzing = true
        analyzer.analyze(image: selectedImage) { result in
            DispatchQueue.main.async {
                self.isAnalyzing = false
                switch result {
                case .success(let nutritionReport):
                    self.report = nutritionReport
                    saveReport(nutritionReport)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveReport(_ report: NutritionReport) {
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
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
