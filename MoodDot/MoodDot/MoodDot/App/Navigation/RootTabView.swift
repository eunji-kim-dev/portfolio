import SwiftUI

struct RootTabView: View {
    @StateObject private var store = MoodStore()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground() // 배경 투명

        // ✅ 비선택: 검정 55%
        let normalColor = UIColor.black.withAlphaComponent(0.55)
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor
        ]

        // ✅ 선택: 검정 100%
        let selectedColor = UIColor.black
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            NavigationStack {
                CalendarHomeView(store: store)
            }
            .tabItem { Label("달력", systemImage: "calendar") }

            NavigationStack {
                RecordsListView(store: store)
            }
            .tabItem { Label("기록", systemImage: "list.bullet") }

            NavigationStack {
                StatsHomeView(store: store)
            }
            .tabItem { Label("통계", systemImage: "chart.bar") }
            
            NavigationStack {
                SettingsHomeView()
            }
            .tabItem { Label("설정", systemImage: "gearshape") }
        }
        .tint(.black)
    }
}

#Preview("RootTabView") {
    RootTabView()
}
