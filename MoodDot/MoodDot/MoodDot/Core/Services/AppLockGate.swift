import SwiftUI

struct AppLockGate<Content: View>: View {
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @StateObject private var lock = AppLockManager()
    @Environment(\.scenePhase) private var scenePhase

    let content: () -> Content

    var body: some View {
        ZStack {
            content()
                .disabled(appLockEnabled && !lock.isUnlocked)

            if appLockEnabled && !lock.isUnlocked {
                lockOverlay
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 앱 첫 진입 시
            if appLockEnabled {
                Task { await lock.unlockIfPossible() }
            } else {
                lock.isUnlocked = true
            }
        }
        .onChange(of: appLockEnabled) { _, on in
            if on {
                lock.lock()
                Task { await lock.unlockIfPossible() }
            } else {
                lock.isUnlocked = true
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // 백그라운드 갔다가 돌아오면 다시 잠금
            if !appLockEnabled { return }

            if phase == .background {
                lock.lock()
            } else if phase == .active {
                Task { await lock.unlockIfPossible() }
            }
        }
    }

    private var lockOverlay: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 34, weight: .bold))

            Text("잠금")
                .font(.system(size: 22, weight: .bold))

            if let msg = lock.lastErrorMessage {
                Text(msg)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            } else {
                Text("Face ID / Touch ID / 암호로 열기")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Button {
                Task { await lock.unlockIfPossible() }
            } label: {
                Text(lock.isAuthenticating ? "인증 중…" : "인증하기")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(lock.isAuthenticating)
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
