import Foundation
import LocalAuthentication

@MainActor
final class AppLockManager: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var lastErrorMessage: String? = nil
    @Published var isAuthenticating: Bool = false

    func lock() {
        isUnlocked = false
        lastErrorMessage = nil
    }

    func unlockIfPossible(reason: String = "앱을 열려면 인증이 필요합니다.") async {
        
        #if targetEnvironment(simulator)
        isUnlocked = true
        lastErrorMessage = nil
        return
        #endif

        guard !isAuthenticating else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }

        let ctx = LAContext()
        ctx.localizedCancelTitle = "취소"

        var err: NSError?
        let canAuth = ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err)

        // 기기에서 인증 자체가 불가하면(시뮬레이터/암호 미설정 등) 앱을 막아두면 사용자가 못 씀.
        // 그래서 이 경우는 "잠금 해제 처리"로 둠. (현실적인 타협)
        guard canAuth else {
            isUnlocked = true
            lastErrorMessage = nil
            return
        }

        do {
            let ok = try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            isUnlocked = ok
            lastErrorMessage = ok ? nil : "인증에 실패했습니다."
        } catch {
            isUnlocked = false
            lastErrorMessage = (error as NSError).localizedDescription
        }
    }
}
