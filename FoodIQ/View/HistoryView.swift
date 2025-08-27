import SwiftUI
import CoreData

struct HistoryView: View {
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \FoodEntry.timestamp, ascending: false)],
            animation: .default
        )
        private var entries: FetchedResults<FoodEntry>  // <-- FetchedResults<T>
        
        var body: some View {
            NavigationStack {
                List {
                    ForEach(entries) { entry in   // <-- Use entries directly
                        VStack(alignment: .leading) {
                            Text(entry.foodName ?? "Unknown Food")
                                .font(.headline)
                            Text("\(entry.calories) kcal • Score: \(entry.qualityScore)")
                                .font(.subheadline)
                            Text(entry.timestamp!, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationTitle("History")
            }
        }
}
