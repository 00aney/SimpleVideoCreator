//
//  CreateVideoViewController.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-26.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import AVKit
import AssetsLibrary
import MobileCoreServices
import UIKit


final class CreateVideoViewController: UIViewController {

  // MARK: Constants
  
  static let frameCount = 6
  
  
  // MARK: UI
  
  @IBOutlet weak var videoContainerView: UIView!
  @IBOutlet weak var frameContainerView: UIView!
  @IBOutlet weak var frameImageView: UIImageView!
  
  @IBOutlet weak var titleTextField: UITextField!
  
  @IBOutlet weak var retakeButton: UIButton!
  @IBOutlet weak var uploadButton: UIButton!
  
  let videoPlayerView: VideoPlayerView = {
    let view = VideoPlayerView(frame:
      CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
    )
    return view
  }()
  
  
  // MARK: Properties
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  var video: Video?
  var videoURL: URL?
  var uploadedURL: URL?
  
  var asset: AVAsset?
  var assetTime: CMTime?
  var assetTimeSeconds: Int?
  
  var isPlaying = false
  var player: AVPlayer?
  var playerLayer: AVPlayerLayer?
  
  var frameImages = [UIButton]()

  
  // MARK: Initializing
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupBinding()
    
    VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func setupUI() {
    title = "Create Video"
    setNeedsStatusBarAppearanceUpdate()
    
    retakeButton.layer.cornerRadius = 8
    uploadButton.layer.cornerRadius = 8
    
    videoContainerView.addSubview(videoPlayerView)
  }
  
  private func setupBinding() {
    titleTextField.delegate = self
    
    // Listen for keyboard events
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChange(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChange(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChange(notification:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )
  }
  
  func createImageFrames() {
    guard let asset = asset else { return }
    
    frameImages.forEach { $0.removeFromSuperview() }
    
    let assetImageGenerator = AVAssetImageGenerator(asset: asset)
    assetImageGenerator.appliesPreferredTrackTransform = true
    assetImageGenerator.requestedTimeToleranceAfter = CMTime.zero
    assetImageGenerator.requestedTimeToleranceBefore = CMTime.zero
    
    let assetTime = asset.duration
    let assetTimeSeconds = Int(CMTimeGetSeconds(assetTime))
    let maxLength = "\(assetTimeSeconds)"
    
    let avgTime = Double(assetTimeSeconds) / Double(CreateVideoViewController.frameCount)
    var startTime: Double = 0
    var startXPosition = CGFloat(0)

    for _ in 0..<CreateVideoViewController.frameCount {
      let imageButton = UIButton()
      imageButton.isUserInteractionEnabled = false
      
      let xPositionSpacing = frameImageView.frame.width / CGFloat(CreateVideoViewController.frameCount)
      imageButton.frame = CGRect(
        x: CGFloat(startXPosition),
        y: CGFloat(0),
        width: xPositionSpacing,
        height: CGFloat(frameImageView.frame.height)
      )
      
      do {
        let time = CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: Int32(maxLength) ?? 0)
        let img = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
        let image = UIImage(cgImage: img)
        imageButton.setImage(image, for: .normal)
      } catch {
        showAlert(title: "Error", message: "Image generation failed with error (error)")
      }
      
      startXPosition = startXPosition + xPositionSpacing
      startTime = startTime + avgTime
      frameImageView.addSubview(imageButton)
      frameImages.append(imageButton)
    }
  }
  
  func fetchVideoAndPlay(id: String) {
    FirestoreService.shared.get(
      from: .videos,
      returning: Video.self,
      id: id,
      completion: { [weak self] (video, error) in
        guard let video = video,
          error == nil
          else {
            self?.showAlert(title: "Error", message: error?.localizedDescription)
            return
        }
      
        guard let self = self,
          let documentDirectoryURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
          ).first
          else { return }
      
        self.video = video
        guard let id = video.id else { return }
      
        let videoFileURL = documentDirectoryURL.appendingPathComponent(id).appendingPathExtension(video.format)
      
        DispatchQueue.main.async {
          let newPlayer = AVPlayer(url: videoFileURL)
          let playerController = AVPlayerViewController()
          let titleLabel = UILabel()
          titleLabel.text = video.title
          titleLabel.backgroundColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
          titleLabel.textColor = .white
          titleLabel.textAlignment = .center
          titleLabel.frame = CGRect(
            x: 0,
            y: 80,
            width: UIScreen.main.bounds.width,
            height: 40
          )
          playerController.player = newPlayer
          self.present(playerController, animated: true, completion: {
            newPlayer.play()
            playerController.view.addSubview(titleLabel)
          })
        }
      }
    )
  }
  
  func saveVideo(filename: String, url: URL?) {
    guard let url = url,
      let documentDirectoryURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      ).first else {
        return
    }
    
    let videoFileURL = documentDirectoryURL.appendingPathComponent(filename).appendingPathExtension(url.pathExtension)
    do {
      try FileManager.default.moveItem(at: url, to: videoFileURL)
      UISaveVideoAtPathToSavedPhotosAlbum(
        videoFileURL.path,
        self,
        #selector(video(_:didFinishSavingWithError:contextInfo:)),
        nil
      )
      
      let data = try Data(contentsOf: videoFileURL)
      self.uplaodVideo(filename: videoFileURL.lastPathComponent, data: data)
    } catch {
      showAlert(title: "Error", message: error.localizedDescription)
    }
  }
  
  @objc func keyboardWillChange(notification: Notification) {
    guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    if notification.name == UIResponder.keyboardWillShowNotification ||
      notification.name == UIResponder.keyboardWillChangeFrameNotification {
      view.frame.origin.y = -keyboardRect.height
    } else {
      view.frame.origin.y = 0
    }
    
  }
  
  func uplaodVideo(filename: String, data: Data) {
    StorageService.shared.uploadVideo(filename: filename, data: data) { [weak self] error in
      guard let self = self else { return }
      if let error = error {
        self.showToast(message: error.localizedDescription, completion: nil)
      } else {
        self.showToast(message: "Video was uploaded on Firebase", completion: nil)
      }
    }
  }
  
  
  // MARK: IBActions
  
  @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
    let message = (error == nil) ? "Video was saved" : "Video failed to save"
    
    showToast(message: message) {
      if error == nil {
        let url = URL(string: videoPath)
        guard let id = url?.lastPathComponent.split(separator: ".").first else { return }
        self.fetchVideoAndPlay(id: String(id))
      }
    }
  }
  
  @IBAction func retakeButtonDidTap(_ sender: Any) {
    titleTextField.text = ""
    VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
  }
  
  @IBAction func uploadButtonDidTap(_ sender: Any) {
    guard let title = titleTextField.text, title.count > 0 else {
      showAlert(title: "Invalid Value", message: "Please enter title")
      return
    }
    
    guard let tracks = asset?.tracks(withMediaType: .video),
      tracks.count > 0,
      let track = tracks.last,
      let assetTimeSeconds = assetTimeSeconds
      else {
        showAlert(title: "No Video", message: "Please record video")
        return
    }
    
    let video = Video(
      title: title,
      length: "\(assetTimeSeconds)",
      resolution: "\(Int(track.naturalSize.width))x\(Int(track.naturalSize.height))",
      format: videoURL?.pathExtension ?? "unknown"
    )
    
    FirestoreService.shared.create(for: video, in: .videos) { [weak self] (id, error)  in
      guard let self = self else { return }
      if let id = id {
        self.saveVideo(filename: id, url: self.videoURL)
      } else if let error = error {
        self.showAlert(title: "Error", message: error.localizedDescription)
      }
    }
  }
  
}


// MARK: - UIImagePickerControllerDelegate

extension CreateVideoViewController: UIImagePickerControllerDelegate {
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    picker.dismiss(animated: true) {
      self.videoPlayerView.player?.play()
    }
    
    guard let mediaType = info[.mediaType] as? String,
      mediaType == (kUTTypeMovie as String),
      let url = info[.mediaURL] as? URL,
      UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
      else {
        return
    }
    
    videoURL = url;
    asset = AVURLAsset.init(url: url)
    
    if let asset = asset {
      assetTime = asset.duration
      assetTimeSeconds = Int(CMTimeGetSeconds(asset.duration))
      
      createImageFrames()
      
      let item = AVPlayerItem(asset: asset)
      videoPlayerView.configure(item)
    }
  }
}


// MARK: - UINavigationControllerDelegate

extension CreateVideoViewController: UINavigationControllerDelegate {
}


// MARK: - UITextFieldDelegate

extension CreateVideoViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
}
