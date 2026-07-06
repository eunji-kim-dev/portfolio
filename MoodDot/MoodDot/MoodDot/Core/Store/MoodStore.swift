import Foundation

final class MoodStore: ObservableObject {
    @Published private(set) var entries: [MoodEntry] = []

    private let key = "mood_entries_v1"

    init() {
        load()
    }

    var allEntriesSorted: [MoodEntry] {
        entries.sorted { $0.date > $1.date }
    }

    func mood(for date: Date) -> Mood? {
        let d = dayKey(date)
        return entries.first(where: { dayKey($0.date) == d })?.mood
    }

    func entry(for date: Date) -> MoodEntry? {
        let d = dayKey(date)
        return entries.first(where: { dayKey($0.date) == d })
    }

    func setMood(_ mood: Mood, for date: Date, fortune: Fortune? = nil) {
        let d = dayKey(date)
        let picked = fortune ?? FortuneBank.pickRandom(mood: mood) ?? Fortune(id: "none", mood: mood, text: "")

        if let idx = entries.firstIndex(where: { dayKey($0.date) == d }) {
            entries[idx].mood = mood
            entries[idx].fortuneId = picked.id
            entries[idx].fortuneText = picked.text
        } else {
            entries.append(MoodEntry(date: d, mood: mood, fortuneId: picked.id, fortuneText: picked.text))
        }
        save()
    }

    func removeMood(for date: Date) {
        let d = dayKey(date)
        entries.removeAll { dayKey($0.date) == d }
        save()
    }

    // ✅ 하루 기준 키 (시간 제거)
    private func dayKey(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Save failed:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            entries = try JSONDecoder().decode([MoodEntry].self, from: data)
        } catch {
            print("Load failed, reset:", error)
            entries = []
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
