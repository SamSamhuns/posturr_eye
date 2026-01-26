import Foundation

// MARK: - Data Models

struct DailyStats: Codable, Identifiable {
    var id: String { dateString }
    let date: Date
    var totalSeconds: TimeInterval
    var slouchSeconds: TimeInterval
    var slouchCount: Int
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var postureScore: Double {
        guard totalSeconds > 0 else { return 100.0 }
        let ratio = max(0, min(1, 1.0 - (slouchSeconds / totalSeconds)))
        return ratio * 100.0
    }
}

// MARK: - Analytics Manager

class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var todayStats: DailyStats
    private var history: [String: DailyStats] = [:]
    private let fileURL: URL
    
    private init() {
        // Setup file path
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("Posturr")
        
        // Ensure directory exists
        try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        self.fileURL = appDir.appendingPathComponent("analytics.json")
        
        // Initialize with default
        let today = Date()
        self.todayStats = DailyStats(date: today, totalSeconds: 0, slouchSeconds: 0, slouchCount: 0)
        
        loadHistory()
        checkDayRollover()
    }
    
    // MARK: - Tracking Methods
    
    func trackTime(interval: TimeInterval, isSlouching: Bool) {
        checkDayRollover()
        
        todayStats.totalSeconds += interval
        if isSlouching {
            todayStats.slouchSeconds += interval
        }
        
        // Update history cache
        history[todayStats.dateString] = todayStats
        
        // Persist periodically (could be optimized to not save every frame, but OS handles small writes well)
        saveHistory()
    }
    
    func recordSlouchEvent() {
        checkDayRollover()
        todayStats.slouchCount += 1
        history[todayStats.dateString] = todayStats
        saveHistory()
    }
    
    // MARK: - Data Retrieval
    
    func getLast7Days() -> [DailyStats] {
        let calendar = Calendar.current
        var result: [DailyStats] = []
        
        // Generate last 7 days including today
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let dateString = formatDate(date)
                if let stats = history[dateString] {
                    result.append(stats)
                } else {
                    // Return empty entry for missing days so charts look correct
                    result.append(DailyStats(date: date, totalSeconds: 0, slouchSeconds: 0, slouchCount: 0))
                }
            }
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    // MARK: - Internal Logic
    
    private func checkDayRollover() {
        let todayString = formatDate(Date())
        if todayStats.dateString != todayString {
            // New day
            todayStats = DailyStats(date: Date(), totalSeconds: 0, slouchSeconds: 0, slouchCount: 0)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: fileURL)
        } catch {
            print("[Analytics] Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
            let data = try Data(contentsOf: fileURL)
            history = try JSONDecoder().decode([String: DailyStats].self, from: data)
            
            // Restore today's stats if they exist in history
            let todayString = formatDate(Date())
            if let existingToday = history[todayString] {
                todayStats = existingToday
            }
        } catch {
            print("[Analytics] Failed to load history: \(error)")
        }
    }
}
