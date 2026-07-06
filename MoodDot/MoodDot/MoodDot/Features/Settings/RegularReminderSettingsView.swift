import SwiftUI

struct RegularReminderSettingsView: View {
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 22
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    @State private var time: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()

    var body: some View {
        Form {
            Section("정기 알림") {
                Toggle("정기 알림", isOn: $reminderEnabled)
                    .onChange(of: reminderEnabled) { _, on in
                        if on {
                            NotificationManager.requestAndScheduleDaily(hour: reminderHour, minute: reminderMinute)
                        } else {
                            NotificationManager.cancelDaily()
                        }
                    }

                DatePicker("시간", selection: $time, displayedComponents: .hourAndMinute)
                    .disabled(!reminderEnabled)
                    .onChange(of: time) { _, newValue in
                        let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        reminderHour = c.hour ?? 22
                        reminderMinute = c.minute ?? 0

                        if reminderEnabled {
                            NotificationManager.requestAndScheduleDaily(hour: reminderHour, minute: reminderMinute)
                        }
                    }
            }

            Section {
                Text("직접 설정한 시간에 알림을 보냅니다.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("정기 알림")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            time = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? Date()
        }
    }
}
