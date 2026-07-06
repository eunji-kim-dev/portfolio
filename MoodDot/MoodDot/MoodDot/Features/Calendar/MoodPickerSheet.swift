import SwiftUI

struct MoodPickerSheet: View {
    let date: Date
    @ObservedObject var store: MoodStore
    @Environment(\.dismiss) private var dismiss

    @State private var pickedMood: Mood? = nil
    @State private var pickedFortune: Fortune? = nil

    private func pretendard(_ name: String, _ size: CGFloat) -> Font {
        .custom("Pretendard-\(name)", size: size)
    }

    var body: some View {
        ZStack {
            // 바깥은 투명
            Color.clear.ignoresSafeArea()

            if let mood = pickedMood, let fortune = pickedFortune {
                fortuneCard(mood: mood, fortune: fortune)
            } else {
                pickerBody
            }
        }
    }

    private var pickerBody: some View {
        VStack(spacing: 18) {
            Text("TODAY")
                .font(pretendard("SemiBold", 20))
                .foregroundStyle(.black)

            HStack(spacing: 14) {
                ForEach(Mood.allCases) { mood in
                    Button {
                        // 감정 선택 → 포춘 1개 뽑고 카드로 이동
                        FortuneBank.loadIfNeeded()
                        pickedMood = mood
                        pickedFortune = FortuneBank.pickRandom(mood: mood)
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(mood.color)
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(Color.black.opacity(0.10), lineWidth: 1))

                            Text(mood.titleKR)
                                .font(pretendard("Medium", 12))
                                .foregroundStyle(Color.black.opacity(0.85))
                        }
                        .frame(width: 55.5)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                store.removeMood(for: date)
                dismiss()
            } label: {
                Text("기록 지우기")
                    .font(pretendard("SemiBold", 14))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.black.opacity(0.18), lineWidth: 1)
                    )
            }
            .padding(.top, 6)
        }
        .padding(20)
        .background(Color(hex: 0xFEFBEC)) // 카드 연노랑
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
        .padding(16)
    }

    private func fortuneCard(mood: Mood, fortune: Fortune) -> some View {
        VStack(spacing: 0) {

            // ✅ TODAY + 문구 영역을 더 크게
            VStack(spacing: 8) {
                Text("TODAY")
                    .font(pretendard("SemiBold", 20))

                Text(fortune.text.isEmpty ? "…" : fortune.text)
                    .font(pretendard("Medium", 15))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 130)          // ✅ 이 값을 키우면 위 칸이 더 커짐 (예: 140~160)
            .padding(.vertical, 12)
            .layoutPriority(1)              // ✅ 공간 부족하면 위가 우선

            Divider()

            // ✅ 버튼 칸은 작게, 높이 고정
            HStack(spacing: 0) {
                Button("Edit") {
                    pickedMood = nil
                    pickedFortune = nil
                }
                .font(pretendard("Medium", 13))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                Button("Done") {
                    store.setMood(mood, for: date, fortune: fortune)
                    dismiss()
                }
                .font(pretendard("Bold", 13))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 44)              // ✅ 버튼 줄 높이 (38~48 사이 취향)
        }
        .background(Color(hex: 0xFEFBEC))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
        .padding(10)
    }
}

#Preview("MoodPickerSheet") {
    MoodPickerSheet(date: Date(), store: MoodStore())
        .presentationDetents([.medium])
        .presentationBackground(.clear)
}
