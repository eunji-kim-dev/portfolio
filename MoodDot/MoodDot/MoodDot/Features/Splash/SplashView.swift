import SwiftUI
import UIKit

// MARK: - Font Extension (UIKit 경유)
extension Font {
    static func pretendardBlack(_ size: CGFloat) -> Font {
        if let uiFont = UIFont(name: "Pretendard-Black", size: size) {
            return Font(uiFont)
        } else {
            // 폰트 못 찾으면 바로 시스템 폰트로 폴백
            return .system(size: size, weight: .black)
        }
    }
}

struct SplashView: View {
    @Binding var goMain: Bool

    var body: some View {
        ZStack {
            Color(red: 248/255.0, green: 247/255.0, blue: 243/255.0)
                .ignoresSafeArea()

            // 그림자
            Text("MOODDOT")
                .font(.pretendardBlack(50))
                .foregroundStyle(.black.opacity(0.5))
                .offset(y: 2.5)
                .blur(radius: 0.9)

            // 본문
            Text("MOODDOT")
                .font(.pretendardBlack(50))
                .foregroundStyle(.white)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    goMain = true
                }
            }
        }
    }
}

#Preview {
    SplashView(goMain: .constant(false))
}
