import SwiftUI
import Charts

struct StatsHomeView: View {
    @ObservedObject var store: MoodStore

    @State private var month: Date = Date()

    private let bg   = Color(hex: 0xF8F7F3)
    private let card = Color(hex: 0xFEFBEC)
    private let tint = Color(hex: 0x97886E)

    var body: some View {
        let stats = monthStats(for: month)

        ZStack {
            bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    header

                    // 요약
                    MDCard(bg: card) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이번 달 기록")
                                .font(pr("SemiBold", 18))

                            Text("\(stats.totalDays)일")
                                .font(pr("ExtraBold", 34))
                                .foregroundStyle(.primary)

                            Text("마음의 흐름을 한눈에")
                                .font(pr("Medium", 13))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                    }

                    // 차트
                    MDCard(bg: card) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("감정 분포")
                                .font(pr("SemiBold", 18))
                                .padding(.top, 16)
                                .padding(.horizontal, 16)

                            if stats.totalDays == 0 {
                                Text("이번 달에는 기록이 없습니다.")
                                    .font(pr("Medium", 14))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                            } else {
                                Chart(stats.rows, id: \.mood.id) { row in
                                    BarMark(
                                        x: .value("Count", row.count),
                                        y: .value("Mood", row.mood.titleKR)
                                    )
                                    .foregroundStyle(row.mood.color)
                                    .cornerRadius(6)
                                }
                                .chartXScale(domain: 0...(max(1, stats.maxCount)))

                                // ✅ 왼쪽 감정 라벨(기쁨/까칠함/슬픔/두려움/분노) 글씨 색: 갈색 틴트
                                .chartYAxis {
                                    AxisMarks { _ in
                                        AxisGridLine().foregroundStyle(.clear)
                                        AxisTick().foregroundStyle(.clear)
                                        AxisValueLabel()
                                            .font(pr("Medium", 12))
                                            .foregroundStyle(tint) // ✅ 변경
                                    }
                                }

                                // ✅ 아래 숫자 라벨(0 등) 글씨 색: 갈색 틴트
                                .chartXAxis {
                                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                                        AxisGridLine().foregroundStyle(Color.black.opacity(0.06))
                                        AxisTick().foregroundStyle(Color.black.opacity(0.12))
                                        AxisValueLabel()
                                            .font(pr("Medium", 11))
                                            .foregroundStyle(tint) // ✅ 변경
                                    }
                                }
                                .frame(height: 190)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 14)
                            }
                        }
                    }

                    // 리스트
                    MDCard(bg: card) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("상세")
                                .font(pr("SemiBold", 18))
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 6)

                            ForEach(stats.rows, id: \.mood.id) { row in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(row.mood.color)
                                        .frame(width: 14, height: 14)

                                    Text(row.mood.titleKR)
                                        .font(pr("SemiBold", 15))

                                    Spacer()

                                    Text("\(row.count)일")
                                        .font(pr("SemiBold", 14))
                                        .foregroundStyle(.primary)

                                    Text("(\(percentString(row.count, stats.totalDays)))")
                                        .font(pr("Medium", 13))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)

                                if row.mood != stats.rows.last?.mood {
                                    Divider()
                                        .overlay(Color.black.opacity(0.06))
                                        .padding(.leading, 16)
                                }
                            }

                            Spacer(minLength: 8)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(16)
            }
        }
        .tint(tint)
    }

    // MARK: - Header (월 중앙 + 화살표 옆)

    private var header: some View {
        HStack(spacing: 10) {
            Button { month = addMonths(month, -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }

            Text(monthTitle(month))
                .font(pr("ExtraBold", 26))
                .foregroundStyle(.primary)

            Button { month = addMonths(month, 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
            }

            Spacer()
        }
        .padding(.top, 6)
    }

    // MARK: - Data

    private func monthStats(for date: Date) -> MonthStats {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: date))!
        let end = cal.date(byAdding: .month, value: 1, to: start)!

        let monthEntries = store.entries.filter { $0.date >= start && $0.date < end }

        var counts: [Mood: Int] = Dictionary(uniqueKeysWithValues: Mood.allCases.map { ($0, 0) })
        for e in monthEntries {
            counts[e.mood, default: 0] += 1
        }

        let rows = Mood.allCases.map { MoodRow(mood: $0, count: counts[$0, default: 0]) }
        let total = monthEntries.count
        let maxCount = rows.map(\.count).max() ?? 0

        return MonthStats(rows: rows, totalDays: total, maxCount: maxCount)
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월"
        return f.string(from: date)
    }

    private func addMonths(_ date: Date, _ value: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: value, to: date) ?? date
    }

    private func percentString(_ count: Int, _ total: Int) -> String {
        guard total > 0 else { return "0%" }
        let p = Double(count) / Double(total) * 100.0
        return String(format: "%.0f%%", p)
    }
}

// MARK: - Models

private struct MonthStats {
    let rows: [MoodRow]
    let totalDays: Int
    let maxCount: Int
}

private struct MoodRow {
    let mood: Mood
    let count: Int
}

// MARK: - UI Helpers (이 파일에서만 쓰는 미니 컴포넌트)

private func pr(_ w: String, _ size: CGFloat) -> Font {
    .custom("Pretendard-\(w)", size: size)
}

private struct MDCard<Content: View>: View {
    let bg: Color
    let content: Content
    init(bg: Color, @ViewBuilder content: () -> Content) {
        self.bg = bg
        self.content = content()
    }
    var body: some View {
        VStack(spacing: 0) { content }
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 10)
    }
}

#Preview("StatsHomeView") {
    StatsHomeView(store: MoodStore())
}
