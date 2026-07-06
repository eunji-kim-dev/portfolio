import SwiftUI

struct AppLockSettingsView: View {
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false

    var body: some View {
        Form {
            Section("앱 잠금") {
                Toggle("비밀번호/Face ID 잠금", isOn: $appLockEnabled)
            }

            Section {
                Text("잠금이 켜져 있으면 앱 실행/복귀 때 인증을 요구합니다.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("앱 잠금")
        .navigationBarTitleDisplayMode(.inline)
    }
}
