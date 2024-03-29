//
//  MusicPlayerViewController.swift
//  MyMusicPlayer
//
//  Created by Jinwoo Kim on 11/02/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit
//import AVFoundation

import SnapKit

/**
 
 
 */
class MusicPlayerViewController: UIViewController {  // View ... Action(User Interaction) ...

    // MARK: - Properties
    
    // MARK: UI
    private lazy var guide = view.safeAreaLayoutGuide
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "button_pause"), for: .selected)
        button.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "00:00:00"
        return label
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .red
        slider.addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
        
        slider.maximumValue =
            Float(self.playerManager.player.duration)
        slider.minimumValue = 0
        slider.value = Float(self.playerManager.player.currentTime)
        
        return slider
    }()
    
    // MARK: General
//    private lazy var player: AVAudioPlayer = AVAudioPlayer()
    private lazy var playerManager = MusicPlayerManager.shared
    private lazy var player = self.playerManager.player
    
    private var timer: Timer?
    
    // MARK: - Initializing
    init() {
        super.init(nibName: nil, bundle: nil)
        playerManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    
    // MARK: - Methods
    
    // MARK: Layout
    private func configureLayout() {
        view.backgroundColor = .white
        
        [playPauseButton, timeLabel, progressSlider].forEach {
            view.addSubview($0)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.centerX.equalTo(guide.snp.centerX)
            make.centerY.equalTo(guide.snp.centerY).multipliedBy(0.7)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(playPauseButton.snp.width)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(guide)
            make.top.equalTo(playPauseButton.snp.bottom).offset(12)
        }
        
        progressSlider.snp.makeConstraints { make in
            make.centerX.equalTo(guide)
            make.top.equalTo(timeLabel.snp.bottom).offset(12)
            make.width.equalToSuperview().offset(-50)
        }
    }
    
    // MARK: General
    @objc private func handleValueChanged() {
        updateTimeLabelText(time: TimeInterval(progressSlider.value))
        guard progressSlider.isTracking == false else {
            return  // 바를 옮기는 중엔 player 를 유지해서 음원 끊김현상 방지
        }
        player.currentTime = TimeInterval(progressSlider.value)
    }
    
    @objc private func handlePlayPause() {
        playPauseButton.isSelected = !playPauseButton.isSelected
        if playPauseButton.isSelected {
            player.play()
            makeAndFireTimer()
        } else {
            player.pause()
            invalidateTimer()
        }
    }
    
    // MARK: Timer
    private func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let currentTimeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        timeLabel.text = currentTimeText
    }
    
    private func makeAndFireTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer: Timer) in
            guard
                let self = self,
                self.progressSlider.isTracking == false else {
                    return
            }
            
            self.updateTimeLabelText(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        guard let timer = timer else {
            print("Timer hasn't created")
            return
        }
        timer.fire()
    }
    
    private func invalidateTimer() {
        guard let timer = timer else {
            print("Timer didn't fired..")
            return
        }
        timer.invalidate()
    }
}

extension MusicPlayerViewController: MusicPlayerManagerDelegate {
    func didFinishPlaying() {
        playPauseButton.isSelected = false
        
        invalidateTimer()
        
        progressSlider.value = 0
        
        updateTimeLabelText(time: 0)
    }
    
    
}
