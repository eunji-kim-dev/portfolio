import SwiftUI

struct BackgroundMusicSettingsView: View {
    @StateObject private var bgm = BGMManager.shared

    private let tracks: [(title: String, file: String)] = [
        ("별빛", "Starlight"),
    ]

    var body: some View {
        Form {
            Section("배경음악") {
                Toggle("음악", isOn: $bgm.isOn)
                    .onChange(of: bgm.isOn) { _, on in
                        if on { bgm.playCurrent() } else { bgm.stop() }
                    }

                Picker("트랙", selection: $bgm.selectedTrack) {
                    ForEach(tracks, id: \.file) { t in
                        Text(t.title).tag(t.file)
                    }
                }
                .disabled(!bgm.isOn)
            }

            Section {
                Button(bgm.isOn ? "재생 중지" : "테스트 재생") {
                    if bgm.isOn {
                        bgm.stop()
                        bgm.isOn = false
                    } else {
                        bgm.isOn = true
                        bgm.playCurrent()
                    }
                }
            }
        }
        .navigationTitle("배경음악")
        .navigationBarTitleDisplayMode(.inline)
    }
}
