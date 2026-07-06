import SwiftUI

struct SettingsHomeView: View {
    // 공통 톤
    private let bg = Color(hex: 0xF8F7F3)
    private let card = Color(hex: 0xFEFBEC)
    private let tint = Color(hex: 0x97886E)

    // 배경음악
    @StateObject private var bgm = BGMManager.shared

    // 앱 잠금
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false

    // 정기 알림
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 22
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    @State private var showTimeSheet = false
    @State private var time: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()

    // 트랙 목록
    private let tracks: [(title: String, file: String)] = [
        ("별빛", "Starlight"),
        ("일들과 나날", "Days-and-Works"),
        ("한밤의 낙원", "Midnight-Paradise"),
        ("눈송이 스치는 바람에도", "Even-though-a-breeze-blowing-on-snowflakes")
    ]

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    // 1) 배경음악
                    MDCard(bg: card) {
                        MDSectionTitle("배경음악 설정")

                        MDRow("음악",
                              trailing: AnyView(
                                Toggle("", isOn: $bgm.isOn)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: tint))
                              )
                        )
                        .onChange(of: bgm.isOn) { _, on in
                            if on { bgm.playCurrent() } else { bgm.stop() }
                        }

                        MDDivider()

                        VStack(spacing: 0) {
                            ForEach(tracks, id: \.file) { t in
                                MDRow(t.title,
                                      isEnabled: bgm.isOn,
                                      action: {
                                          bgm.selectedTrack = t.file
                                          bgm.isOn = true
                                          bgm.playCurrent()
                                      },
                                      trailing: AnyView(
                                        Image(systemName: bgm.selectedTrack == t.file ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(bgm.selectedTrack == t.file ? tint : .secondary)
                                      )
                                )
                                if t.file != tracks.last?.file { MDDivider() }
                            }
                        }
                    }

                    // 2) 앱 잠금
                    MDCard(bg: card) {
                        MDSectionTitle("앱 잠금")

                        MDRow("비밀번호 잠금",
                              subtitle: "앱 실행 및 복귀 시 인증을 요구합니다.",
                              trailing: AnyView(
                                Toggle("", isOn: $appLockEnabled)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: tint))
                              )
                        )
                    }

                    // 3) 정기 알림
                    MDCard(bg: card) {
                        MDSectionTitle("정기 알림")

                        MDRow("알림",
                              subtitle: "직접 설정한 시간에 알림을 보냅니다.",
                              trailing: AnyView(
                                Toggle("", isOn: $reminderEnabled)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: tint))
                              )
                        )
                        .onChange(of: reminderEnabled) { _, on in
                            if on {
                                NotificationManager.requestAndScheduleDaily(hour: reminderHour, minute: reminderMinute)
                            } else {
                                NotificationManager.cancelDaily()
                            }
                        }

                        MDDivider()

                        MDRow("알림 시간",
                              subtitle: reminderEnabled ? nil : "알림을 켜면 선택할 수 있어요.",
                              isEnabled: reminderEnabled,
                              action: {
                                  showTimeSheet = true
                              },
                              trailing: AnyView(
                                HStack(spacing: 8) {
                                    Text(timeString(reminderHour, reminderMinute))
                                        .font(MDFont.semiBold(15))
                                        .foregroundStyle(.secondary)

                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                              )
                        )
                    }

                    Spacer(minLength: 18)
                }
                .padding(16)
            }
        }
        .tint(tint)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            time = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
        }
        .sheet(isPresented: $showTimeSheet) {
            timeSheet
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)

            Text("설정")
                .font(MDFont.extraBold(26))
                .foregroundStyle(tint)

            Spacer()
        }
        .padding(.top, 6)
    }

    // MARK: - Time sheet

    private var timeSheet: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            VStack(spacing: 12) {
                Text("알림 시간")
                    .font(MDFont.extraBold(18))

                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                Button {
                    let c = Calendar.current.dateComponents([.hour, .minute], from: time)
                    reminderHour = c.hour ?? 22
                    reminderMinute = c.minute ?? 0

                    if reminderEnabled {
                        NotificationManager.requestAndScheduleDaily(hour: reminderHour, minute: reminderMinute)
                    }
                    showTimeSheet = false
                } label: {
                    Text("완료")
                        .font(MDFont.semiBold(16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(card)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(16)
        }
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    private func timeString(_ h: Int, _ m: Int) -> String {
        let d = Calendar.current.date(from: DateComponents(hour: h, minute: m)) ?? Date()
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        return f.string(from: d)
    }
}

// MARK: - UI Components

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

private struct MDSectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(MDFont.semiBold(20))
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 6)
    }
}

private struct MDRow: View {
    let title: String
    var subtitle: String? = nil
    var isEnabled: Bool = true
    var action: (() -> Void)? = nil
    var trailing: AnyView

    init(_ title: String,
         subtitle: String? = nil,
         isEnabled: Bool = true,
         action: (() -> Void)? = nil,
         trailing: AnyView) {
        self.title = title
        self.subtitle = subtitle
        self.isEnabled = isEnabled
        self.action = action
        self.trailing = trailing
    }

    var body: some View {
        let row = HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MDFont.semiBold(16))
                    .foregroundStyle(isEnabled ? .primary : .secondary)

                if let subtitle {
                    Text(subtitle)
                        .font(MDFont.medium(13))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())

        Group {
            if let action {
                Button(action: action) { row }.buttonStyle(.plain)
            } else {
                row
            }
        }
        .opacity(isEnabled ? 1.0 : 0.45)
        .disabled(!isEnabled)
    }
}

private struct MDDivider: View {
    var body: some View {
        Divider()
            .overlay(Color.black.opacity(0.06))
            .padding(.leading, 16)
    }
}

#Preview("SettingsHomeView") {
    NavigationStack {
        SettingsHomeView()
    }
}
