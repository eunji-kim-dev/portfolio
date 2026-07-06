import SwiftUI

struct CalendarHomeView: View {
    @State private var month: Date = Date()
    @State private var selected: Date? = nil

    // 샘플: 날짜별 무드 컬러 (나중에 DB/저장소로 교체)
    private var moodByDate: [Date: Color] {
        let cal = Calendar.current
        let base = cal.date(from: cal.dateComponents([.year, .month], from: month))!

        func d(_ day: Int) -> Date {
            cal.date(byAdding: .day, value: day - 1, to: base)!
        }

        return [
            d(1): Color(hex: 0xF2C94C),  // 노랑
            d(2): Color(hex: 0x6FCF97),  // 초록
            d(3): Color(hex: 0xBB6BD9),  // 보라
            d(4): Color(hex: 0x2F80ED),  // 파랑
            d(5): Color(hex: 0x6FCF97),
        ]
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)
    private let weekday = ["S","M","T","W","T","F","S"] // 스샷 느낌

    var body: some View {
        ZStack {
            Color(hex: 0xF8F7F3).ignoresSafeArea()

            VStack(spacing: 14) {
                header

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(weekday, id: \.self) { w in
                        Text(w)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 18)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(monthGridDays(for: month), id: \.self) { day in
                        if let day {
                            dayCell(day)
                        } else {
                            Color.clear.frame(height: 34)
                        }
                    }
                }
                .padding(.horizontal, 18)

                Spacer(minLength: 0)
            }
            .padding(.top, 18)
        }
    }

    private var header: some View {
        HStack {
            Text(monthTitle(month))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            Spacer()

            Button {
                // TODO: Settings 화면으로 이동
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 18)
    }

    private func dayCell(_ date: Date) -> some View {
        let cal = Calendar.current
        let day = cal.component(.day, from: date)
        let mood = moodByDate[stripTime(date)]
        let isSelected = selected.map { cal.isDate($0, inSameDayAs: date) } ?? false

        return Text("\(day)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(mood == nil ? .primary : .white)
            .frame(width: 34, height: 34)
            .background(
                ZStack {
                    if let mood {
                        Circle().fill(mood)
                    }
                    if isSelected {
                        Circle().stroke(Color.black.opacity(0.6), lineWidth: 2)
                    }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture { selected = date }
    }

    // 월 그리드(6주=42칸) 만들기
    private func monthGridDays(for anyDayInMonth: Date) -> [Date?] {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: anyDayInMonth))!
        let range = cal.range(of: .day, in: .month, for: startOfMonth)!
        let numberOfDays = range.count

        // 일요일=1 기준으로 앞에 빈칸
        let firstWeekday = cal.component(.weekday, from: startOfMonth) // 1...7
        let leadingBlanks = firstWeekday - 1

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for day in 1...numberOfDays {
            let date = cal.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            result.append(date)
        }

        while result.count < 42 { result.append(nil) } // 6주 고정
        return result
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func stripTime(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}
