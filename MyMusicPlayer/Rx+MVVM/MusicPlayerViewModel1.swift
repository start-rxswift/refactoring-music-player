//
//  MusicPlayerViewModel1.swift
//  MyMusicPlayer
//
//  Created by Jinwoo Kim on 23/10/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa


class MusicPlayerViewModel1 {
    // MARK: - Properties
    
    
    // Input
    let didTapPlayAndPause = PublishSubject<Bool>()
    
    
    // Output
    let isSelectedState: Driver<Bool>
    
    
    let playerManager: MusicPlayerManager
    
    var timer: Timer?
    
    var duration: TimeInterval {
        self.playerManager.player.duration
    }
    
    var currentTime: TimeInterval {
        self.playerManager.player.currentTime
    }
    
    // MARK: - Initiazing
    init(playerManager: MusicPlayerManager = MusicPlayerManager()) {
        self.playerManager = playerManager
        
        // Rx
        self.isSelectedState = didTapPlayAndPause
            .flatMap {
                return Observable.just(!$0)
        }
        .asDriver(onErrorJustReturn: false)
        
    }
    
    func play() {
        playerManager.player.play()
    }
    
    func pause() {
        playerManager.player.pause()
    }
    
    func updateTimeLabelText(time: TimeInterval) -> String {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let currentTimeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        return currentTimeText
    }
}
