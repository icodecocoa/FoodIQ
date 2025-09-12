# FoodIQ 🍎📱

FoodIQ is an iOS app that analyzes the nutritional quality of food using **Google Gemini API**.  
It combines AI-powered food recognition with **Core Data storage** to let users track what they eat.

---

## 🚀 Features

- 📸 Capture food photos via camera or gallery  
- 🤖 AI-powered nutrition analysis (calories, macros, sodium, quality score)  
- 🧠 Uses **Google Gemini API** for vision + text processing  
- 💾 Save analyzed food entries in **Core Data**  
- 📊 View history of meals with nutrition reports  
- 🔐 Works fully on-device with optional cloud API calls  

---

## 🛠 Technical Details

### Architecture
- **SwiftUI** for UI layer  
- **MVVM** pattern for separation of concerns  
- **Core Data** for local persistence (`FoodEntry` entity)  
- **Google Gemini API (GenerativeModel)** for image + text analysis  
- **Async/Await** used for API calls  
- **JSONDecoder** for parsing AI responses  

### Data Model (`FoodEntry`)
```swift
class FoodEntry: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var timestamp: Date
    @NSManaged var calories: Int32
    @NSManaged var protein: Int32
    @NSManaged var carbs: Int32
    @NSManaged var fat: Int32
    @NSManaged var sodium: Int32
    @NSManaged var qualityScore: Double
    @NSManaged var notes: String?
}
```

### Persistence
```swift
struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FoodIQModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
    }
}
```

### AI Integration (Gemini)
```swift
let model = GenerativeModel(name: "gemini-2.5-flash")

let response = try await model.generateContent([
    foodImage,
    "Analyze this food image and return JSON with calories, protein, carbs, fat, sodium, qualityScore, notes."
])
```

### JSON Extraction
The app safely extracts JSON between `{}` from Gemini responses before decoding into `NutritionReport`.

---

## 📲 Usage Flow
1. Open app → capture or select food image  
2. Gemini analyzes → returns structured nutrition JSON  
3. App decodes into `NutritionReport`  
4. User can save report → persists in Core Data  
5. History tab shows all past meals with details  

---

## 📦 Requirements
- iOS 17+  
- Xcode 15+  
- Swift 5.9+  
- Google Firebase AI SDK (for Gemini API)  

---

## 🌟 Roadmap
**- Add barcode scanning for packaged foods - Implemented**
- Offline nutrition database fallback  
- Meal planning & health insights  
- Sync across devices with iCloud  

---

## 👤 Author
Developed by **Drashti Lakhani** (Senior iOS Engineer)  
