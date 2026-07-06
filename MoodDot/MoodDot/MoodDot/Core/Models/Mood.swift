import SwiftUI

enum Mood: String, CaseIterable, Codable, Identifiable {
    case joy, disgust, sadness, fear, anger
    var id: String { rawValue }

    var titleKR: String {
        switch self {
        case .joy: return "기쁨"
        case .disgust: return "까칠함"
        case .sadness: return "슬픔"
        case .fear: return "두려움"
        case .anger: return "분노"
        }
    }

    var color: Color {
        switch self {
        case .joy:     return Color(hex: 0xFFD86B)
        case .disgust: return Color(hex: 0xABD596)
        case .sadness: return Color(hex: 0x88B6F2)
        case .fear:    return Color(hex: 0xC5AFE7)
        case .anger:   return Color(hex: 0xFF83A2)
        }
    }
}
