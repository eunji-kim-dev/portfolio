import SwiftUI
import UIKit

enum MDFont {
    static func medium(_ size: CGFloat) -> Font {
        custom("Pretendard-Medium", size: size, fallback: .system(size: size, weight: .regular))
    }

    static func semiBold(_ size: CGFloat) -> Font {
        custom("Pretendard-SemiBold", size: size, fallback: .system(size: size, weight: .semibold))
    }

    static func extraBold(_ size: CGFloat) -> Font {
        custom("Pretendard-ExtraBold", size: size, fallback: .system(size: size, weight: .bold))
    }

    private static func custom(_ name: String, size: CGFloat, fallback: Font) -> Font {
        // 폰트가 번들에 제대로 로드됐는지 체크 (안 되면 fallback으로 내려감)
        if UIFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return fallback
    }
}
