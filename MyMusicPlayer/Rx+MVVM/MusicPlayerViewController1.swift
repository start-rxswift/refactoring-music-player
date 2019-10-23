//
//  MusicPlayerViewController1.swift
//  MyMusicPlayer
//
//  Created by Jinwoo Kim on 23/10/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit
//import AVFoundation

import RxSwift
import RxCocoa

import SnapKit

class MusicPlayerViewController1: UIViewController {  // View ... Action(User Interaction) ...

    // MARK: - Properties
    
    // MARK: UI
    private lazy var guide = view.safeAreaLayoutGuide
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "button_pause"), for: .selected)
//        button.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
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
        
        let duration = self.viewModel.duration
        let currentTime = self.viewModel.currentTime
        
        slider.maximumValue = Float(duration)
        slider.minimumValue = 0
        slider.value = Float(currentTime)
        
        return slider
    }()
    
    // MARK: General
    private let disposeBag = DisposeBag()
    
    private var viewModel: MusicPlayerViewModel1
    
    // MARK: - Initializing
    init(viewModel: MusicPlayerViewModel1 = MusicPlayerViewModel1()) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.configure(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    
    // MARK: Binding
    private func configure(viewModel: MusicPlayerViewModel1) {
        playPauseButton.rx.tap
            .asDriver()
            .drive(onNext: { [unowned self] _ in
                let state = self.playPauseButton.isSelected
                self.viewModel.didTapPlayAndPause.onNext(state)
            })
            .disposed(by: disposeBag)
        
        viewModel.isSelectedState
            .asObservable()
            .bind(to: playPauseButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.isSelectedState
            .drive(onNext: { [unowned self] isSelected in
                
                log.debug("State: \(isSelected)")
                
                if isSelected {
                    self.viewModel.play()
                    self.makeAndFireTimer()
                } else {
                    self.viewModel.pause()
                    self.invalidateTimer()
                }
            })
            .disposed(by: disposeBag)
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
        updateSubview(with: TimeInterval(progressSlider.value))
        guard progressSlider.isTracking == false else {
            return  // 바를 옮기는 중엔 player 를 유지해서 음원 끊김현상 방지
        }
        
        viewModel.playerManager.player.currentTime = TimeInterval(progressSlider.value)
    }
    
    private func updateSubview(with time: TimeInterval) {
        timeLabel.text = viewModel.updateTimeLabelText(time: time)
    }
    
    //    @objc private func handlePlayPause() {
    //        playPauseButton.isSelected = !playPauseButton.isSelected
    //
    //        if playPauseButton.isSelected {
    //            viewModel.play()
    //            makeAndFireTimer()
    //        } else {
    //            viewModel.pause()
    //            invalidateTimer()
    //        }
    //    }
    
    // MARK: Timer
    // FIXME: 고쳐야함
    private func makeAndFireTimer() {
        viewModel.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer: Timer) in
            guard
                let self = self,
                self.progressSlider.isTracking == false else {
                    return
            }
            
            let time = self.viewModel.currentTime
            self.updateSubview(with: time)
            self.progressSlider.value = Float(time)
        })
        
        guard let timer = viewModel.timer else {
            print("Timer hasn't created")
            return
        }
        timer.fire()
    }
    
    private func invalidateTimer() {
        guard let timer = viewModel.timer else {
            print("Timer didn't fired..")
            return
        }
        timer.invalidate()
    }
}

extension MusicPlayerViewController1: MusicPlayerManagerDelegate {
    func didFinishPlaying() {
        playPauseButton.isSelected = false
        invalidateTimer()
        progressSlider.value = 0
        updateSubview(with: 0)
    }
}
