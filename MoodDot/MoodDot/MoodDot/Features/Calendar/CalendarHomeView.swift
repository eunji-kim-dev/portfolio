import SwiftUI

struct CalendarHomeView: View {
    @ObservedObject var store: MoodStore

    @State private var month: Date = Date()
    @State private var selectedDay: Date? = nil
    @State private var picked: PickedDay? = nil

    private let weekday = ["S","M","T","W","T","F","S"]

    private let navTint = Color(hex: 0x97886E)
    private let bg = Color(hex: 0xF8F7F3)

    private let hPadding: CGFloat = 14
    private let gridSpacing: CGFloat = 6
    private let minCell: CGFloat = 28

    // 예: "January2025" ... "December2025"
    private var backgroundImageName: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMMyyyy"
        return f.string(from: month)
    }

    var body: some View {
        GeometryReader { geo in
            // 화면 폭 기준 셀 자동 계산
            let available = geo.size.width - (hPadding * 2)
            let cell = (available - (gridSpacing * 6)) / 7
            let cellSize = max(minCell, cell)

            let gridWidth = (cellSize * 7) + (gridSpacing * 6)
            let columns = Array(repeating: GridItem(.fixed(cellSize), spacing: gridSpacing, alignment: .center), count: 7)

            ZStack {
                // 1. 기본 배경색
                bg.ignoresSafeArea()

                // 2. 배경 일러스트
                if UIImage(named: backgroundImageName) != nil {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)

                        Image(backgroundImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    stops: [
                                        .init(color: bg.opacity(0.95), location: 0.00),
                                        .init(color: bg.opacity(0.25), location: 0.30),
                                        .init(color: bg.opacity(0.25), location: 0.78),
                                        .init(color: bg.opacity(0.95), location: 1.00),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }

                // 3. 달력 컨텐츠
                VStack(spacing: 10) {
                    header
                        .padding(.horizontal, hPadding)

                    // 요일 줄
                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                        ForEach(Array(weekday.enumerated()), id: \.offset) { _, w in
                            Text(w)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: cellSize, height: 16)
                        }
                    }
                    .frame(width: gridWidth)
                    .frame(maxWidth: .infinity, alignment: .center)

                    // 날짜 그리드
                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                        ForEach(monthGridDays(for: month), id: \.self) { day in
                            if let day {
                                dayCell(day, cellSize: cellSize)
                            } else {
                                Color.clear.frame(width: cellSize, height: cellSize)
                            }
                        }
                    }
                    .frame(width: gridWidth)
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 14)
            }
            .tint(navTint)
            .sheet(item: $picked) { picked in
                MoodPickerSheet(date: picked.date, store: store)
                    .presentationDetents([.height(230)])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.clear)
            }
        }
    }

    // MARK: - Header (✅ 연도 + 월)

    private var header: some View {
        HStack {
            Button { month = addMonths(month, -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(navTint)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(yearTitle(month))                 // ✅ 2025
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(navTint.opacity(0.9))

                Text(monthTitle(month))                // ✅ December
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button { month = addMonths(month, 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(navTint)
                    .frame(width: 44, height: 44)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Day cell

    private func dayCell(_ date: Date, cellSize: CGFloat) -> some View {
        let cal = Calendar.current
        let day = cal.component(.day, from: date)

        let mood = store.mood(for: date)
        let isSelected = selectedDay.map { cal.isDate($0, inSameDayAs: date) } ?? false

        return Text("\(day)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(mood == nil ? .primary : .white)
            .frame(width: cellSize, height: cellSize)
            .background(
                ZStack {
                    if let mood { Circle().fill(mood.color) }
                    if isSelected { Circle().stroke(Color.black.opacity(0.55), lineWidth: 2) }
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectedDay = date
                picked = PickedDay(date: date)
            }
    }

    // MARK: - Helper Methods

    private func monthGridDays(for anyDayInMonth: Date) -> [Date?] {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: anyDayInMonth))!
        let range = cal.range(of: .day, in: .month, for: startOfMonth)!
        let numberOfDays = range.count

        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        let leadingBlanks = firstWeekday - 1

        var result: [Date?] = Array(repeating: nil, count: leadingBlanks)

        for d in 1...numberOfDays {
            let date = cal.date(byAdding: .day, value: d - 1, to: startOfMonth)!
            result.append(date)
        }

        while result.count < 42 { result.append(nil) }
        return result
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM"
        return f.string(from: date)
    }

    private func yearTitle(_ date: Date) -> String {
        let y = Calendar.current.component(.year, from: date)
        return "\(y)" // 원하면 "\(y)년"
    }

    private func addMonths(_ date: Date, _ value: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: value, to: date) ?? date
    }
}

struct PickedDay: Identifiable {
    let id = UUID()
    let date: Date
}

#Preview("CalendarHomeView") {
    CalendarHomeView(store: MoodStore())
}
