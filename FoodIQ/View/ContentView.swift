import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CaptureView()
                .tabItem {
                    Label("Capture", systemImage: "camera")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
        }
    }
}