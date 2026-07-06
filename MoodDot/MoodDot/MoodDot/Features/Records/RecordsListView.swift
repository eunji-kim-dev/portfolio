import SwiftUI

struct RecordsListView: View {
    private let bg   = Color(hex: 0xF8F7F3)
    private let card = Color(hex: 0xFEFBEC)
    private let tint = Color(hex: 0x97886E)

    @ObservedObject var store: MoodStore

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if store.allEntriesSorted.isEmpty {
                        Text("아직 기록이 없습니다.\n달력에서 날짜를 눌러 감정을 남기세요.")
                            .font(MDFont.medium(14))
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                    } else {
                        ForEach(store.allEntriesSorted) { entry in
                            recordCard(entry)
                        }
                    }

                    Spacer(minLength: 18)
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "list.bullet")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)

            Text("기록")
                .font(MDFont.extraBold(26))
                .foregroundStyle(tint)

            Spacer()
        }
        .padding(.top, 6)
    }

    @ViewBuilder
    private func recordCard(_ entry: MoodEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(entry.mood.color)
                    .frame(width: 12, height: 12)

                Text(dateString(entry.date))
                    .font(MDFont.semiBold(15))
                    .foregroundStyle(.primary)

                Spacer()

                Text(entry.mood.titleKR)
                    .font(MDFont.semiBold(13))
                    .foregroundStyle(tint)
            }

            Text(entry.fortuneText.isEmpty ? "문구 없음" : entry.fortuneText)
                .font(MDFont.medium(14))
                .foregroundStyle(.primary)
                .lineSpacing(3)

            HStack {
                Spacer()
                Button {
                    store.removeMood(for: entry.date)
                } label: {
                    Text("삭제")
                        .font(MDFont.semiBold(12))
                        .foregroundStyle(.primary) // 검정 계열
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 10)
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd (E)"
        return f.string(from: date)
    }
}

#Preview("RecordsListView") {
    NavigationStack {
        RecordsListView(store: MoodStore())
    }
}
