import Foundation

struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date   // 반드시 startOfDay로 저장
    var mood: Mood
    var fortuneId: String
    var fortuneText: String
}

func dayKey(_ date: Date) -> Date {
    Calendar.current.startOfDay(for: date)
}
