//
//  VideoPlayerView.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import AVFoundation
import UIKit


final class VideoPlayerView: UIView {
  
  // MARK: UI
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv =  UIActivityIndicatorView(style: .whiteLarge)
    aiv.translatesAutoresizingMaskIntoConstraints = false
    aiv.startAnimating()
    return aiv
  }()
  
  let pausePlayButton: UIButton = {
    let button = UIButton(type: .system)
    let image = UIImage(named: "icon-pause")
    button.setImage(image, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.tintColor = .white
    button.isHidden = true
    button.addTarget(self, action: #selector(pauseButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  let playerLayer: AVPlayerLayer = {
    let playerLayer = AVPlayerLayer(player: nil)
    return playerLayer
  }()
  
  let controlsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 1)
    return view
  }()
  
  let videoLengthLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize: 13)
    label.textAlignment = .right
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let currentTimeLabel:  UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize: 13)
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let videoSlider: UISlider = {
    let slider = Slider()
    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumTrackTintColor = .red
    slider.maximumTrackTintColor = .white
    let image = UIImage(named: "icon-thumb")?.withRenderingMode(.alwaysTemplate)
    slider.setThumbImage(image, for: .normal)
    slider.tintColor = .red
    slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    return slider
  }()
  
  
  // MARK: Properteis
  
  var playerItem: AVPlayerItem?
  var player: AVPlayer?
  var isPlaying = false
  
  
  // MARK: Initializing
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
    
    backgroundColor = .black
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  // MARK: Configuring
  
  func configure(_ playerItem: AVPlayerItem) {
    self.playerItem = playerItem
    setupPlayerView(playerItem: playerItem)
  }
  
  private func setupUI() {
    playerLayer.frame = self.frame
    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    layer.addSublayer(playerLayer)
    
    controlsContainerView.frame = frame
    addSubview(controlsContainerView)
    
    setupGradientLayer()
    
    controlsContainerView.addSubview(activityIndicatorView)
    activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    controlsContainerView.addSubview(pausePlayButton)
    pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    pausePlayButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
    pausePlayButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    pausePlayButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
    controlsContainerView.addSubview(videoLengthLabel)
    videoLengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4).isActive = true
    videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
    videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
    
    controlsContainerView.addSubview(currentTimeLabel)
    currentTimeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
    currentTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
    currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
    
    controlsContainerView.addSubview(videoSlider)
    videoSlider.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    videoSlider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    videoSlider.centerYAnchor.constraint(equalTo: bottomAnchor).isActive = true
    videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
  }
  
  private func setupPlayerView(playerItem: AVPlayerItem) {
    let player = AVPlayer(playerItem: playerItem)
    self.player = player
    playerLayer.player = player
    
    player.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    
    // track player prgress
    let interval = CMTime(value: 1, timescale: 2) // 1 second
    player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] (progressTime) in
      guard let self = self else { return }
      let seconds = CMTimeGetSeconds(progressTime)
      
      let secondsString = String(format: "%02d", Int(seconds) % 60)
      let minutesString = String(format: "%02d", Int(seconds) / 60)
      self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
      
      if let duration = player.currentItem?.duration {
        let durationSeconds = CMTimeGetSeconds(duration)
        self.videoSlider.value = Float(seconds / durationSeconds)
        
        if(self.videoSlider.value == self.videoSlider.maximumValue) {
          // play again
          player.seek(to: CMTime.zero)
          player.play()
        }
      }
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "loadedTimeRanges" {
      activityIndicatorView.stopAnimating()
      controlsContainerView.backgroundColor = .clear
      pausePlayButton.isHidden = false
      isPlaying = true
      
      if let duration = player?.currentItem?.duration {
        let seconds = CMTimeGetSeconds(duration)
        let secondsString = String(format: "%02d", Int(seconds) % 60)
        let minutesString = String(format: "%02d", Int(seconds) / 60)
        videoLengthLabel.text = "\(minutesString):\(secondsString)"
      }
    }
  }
  
  private func setupGradientLayer() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    gradientLayer.locations = [0.7, 1.2]
    controlsContainerView.layer.addSublayer(gradientLayer)
  }
  
  
  // MARK: Actions
  
  @objc func pauseButtonDidTap() {
    
    if isPlaying {
      player?.pause()
      pausePlayButton.setImage(UIImage(named: "icon-play"), for: .normal)
    } else {
      player?.play()
      pausePlayButton.setImage(UIImage(named: "icon-pause"), for: .normal)
    }
    isPlaying = !isPlaying
  }
  
  
  @objc func sliderValueChanged() {
    if let duration = player?.currentItem?.duration {
      let totalSeconds = CMTimeGetSeconds(duration)
      let value = Float64(videoSlider.value) * totalSeconds
      let seekTime = CMTime(value: Int64(value), timescale: 1)
      player?.seek(to: seekTime, completionHandler: { (completedSeek) in
        // do something
      })
    }
  }
  
}
