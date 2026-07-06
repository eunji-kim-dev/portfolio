import Foundation
import AVFoundation

final class BGMManager: ObservableObject {
    static let shared = BGMManager()

    @Published var isOn: Bool = false {
        didSet { isOn ? playCurrent() : stop() }
    }
    @Published var selectedTrack: String = "Starlight" {
        didSet { if isOn { playCurrent() } }
    }

    private var player: AVAudioPlayer?

    private init() {}

    func playCurrent() {
        guard let url = Bundle.main.url(forResource: selectedTrack, withExtension: "mp3") else {
            print("❌ mp3 not found:", selectedTrack)
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.8
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("❌ audio error:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
