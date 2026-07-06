import Foundation

enum FortuneBank {
    private static var loaded = false
    private static var byMood: [Mood: [Fortune]] = [:]

    static func loadIfNeeded() {
        guard !loaded else { return }
        loaded = true

        guard let url = Bundle.main.url(forResource: "fortunes", withExtension: "csv") else {
            print("fortunes.csv not found in bundle")
            byMood = [:]
            return
        }

        do {
            var raw = try String(contentsOf: url, encoding: .utf8)
            
            // UTF-8 BOM 제거
            if raw.hasPrefix("\u{feff}") { raw.removeFirst() }

            let lines = raw.split(whereSeparator: \.isNewline).map(String.init)
            guard lines.count >= 2 else { return }

            // 헤더로 구분자 감지: 탭/콤마 둘 다 대응
            let header = lines[0]
            let delimiter: Character = header.contains("\t") ? "\t" : ","

            let headerCols = parseLine(header, delimiter: delimiter).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard
                let moodIdx = headerCols.firstIndex(of: "mood"),
                let textIdx = headerCols.firstIndex(of: "text"),
                let idIdx   = headerCols.firstIndex(of: "id")
            else {
                print("CSV header must include: mood, text, id")
                return
            }

            var temp: [Mood: [Fortune]] = [:]

            for line in lines.dropFirst() {
                let cols = parseLine(line, delimiter: delimiter)
                if cols.count <= max(moodIdx, textIdx, idIdx) { continue }

                let moodRaw = cols[moodIdx].trimmingCharacters(in: .whitespacesAndNewlines)
                let text    = cols[textIdx].trimmingCharacters(in: .whitespacesAndNewlines)
                let id      = cols[idIdx].trimmingCharacters(in: .whitespacesAndNewlines)

                guard let mood = Mood(rawValue: moodRaw), !text.isEmpty, !id.isEmpty else { continue }

                temp[mood, default: []].append(Fortune(id: id, mood: mood, text: text))
            }

            byMood = temp
            print("Fortunes loaded:", byMood.mapValues { $0.count })

        } catch {
            print("Failed to read fortunes.csv:", error)
        }
    }

    /// 랜덤 1개 뽑기
    static func pickRandom(mood: Mood) -> Fortune? {
        loadIfNeeded()
        guard let list = byMood[mood], !list.isEmpty else { return nil }
        return list.randomElement()
    }

    /// “같은 날이면 같은 문구” 고정 뽑기(원하면 사용)
    static func pickDaily(mood: Mood, date: Date) -> Fortune? {
        loadIfNeeded()
        guard let list = byMood[mood], !list.isEmpty else { return nil }
        let day = Calendar.current.startOfDay(for: date)
        let seed = Int(day.timeIntervalSince1970) ^ mood.rawValue.hashValue
        let idx = abs(seed) % list.count
        return list[idx]
    }

    // 따옴표 포함 CSV도 대충 버티는 파서(엑셀 기본 출력 대응)
    private static func parseLine(_ line: String, delimiter: Character) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        var chars = Array(line)

        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == "\"" {
                // "" 이스케이프 처리
                if inQuotes, i + 1 < chars.count, chars[i + 1] == "\"" {
                    current.append("\"")
                    i += 1
                } else {
                    inQuotes.toggle()
                }
            } else if c == delimiter, !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(c)
            }
            i += 1
        }
        result.append(current)
        return result
    }
}
