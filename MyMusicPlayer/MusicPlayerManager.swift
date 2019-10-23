

import UIKit
import AVFoundation

class MusicPlayerManager: NSObject {
    
    static let shared = MusicPlayerManager()
    
    lazy var player: AVAudioPlayer = AVAudioPlayer()
    
    weak var delegate: MusicPlayerManagerDelegate?
    
    override init() {
        super.init()
        
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다. ")
            return
        }
        
        do {
            self.player = try AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드: \(error.code), 메세지: \(error.localizedDescription)")
        }
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}

extension MusicPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didFinishPlaying()
    }
}

protocol MusicPlayerManagerDelegate: class {
    func didFinishPlaying()
}
