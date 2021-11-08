//
//  ContentView.swift
//  Audio
//
//  Created by Addin Satria on 08/11/21.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct ContentView: View {
  @ObservedObject var presenter = Presenter()
  
  var body: some View {
    HStack {
      Spacer()
      Button(action: {
        presenter.togglePlayPause()
      }) {
        Text(presenter.isPlaying ? "PAUSE" : "PLAY")
      }
      Spacer()
    }
    .onAppear {
      presenter.setUpPlayer()
      presenter.setupRemoteTransportControls()
      presenter.setupNowPlaying()
    }
  }
}

class Presenter: ObservableObject {
  
  var player = AVAudioPlayer()

  @Published var isPlaying = false
  
  init() {
 
  }
  
  func togglePlayPause() {
    if player.isPlaying {
      pause()
    } else {
      play()
    }
  }
  
  func play() {
    player.play()
    isPlaying.toggle()
    updateNowPlaying(isPause: false)
    print("Play - current time: \(player.currentTime) - is playing: \(player.isPlaying)")
  }
  
  func pause() {
    player.pause()
    isPlaying.toggle()
    updateNowPlaying(isPause: true)
    print("Pause - current time: \(player.currentTime) - is playing: \(player.isPlaying)")
  }
  
  func setUpPlayer() {
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
    } catch let error as NSError {
        print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
    }
    
    guard let fileURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/alpa-5e940.appspot.com/o/ALLAH%20AKAN%20GANTI.mp3?alt=media&token=2dcd5a6b-1da6-4112-93ef-0bdab00b0b67") else { return }
    do {
      let soundData = try Data(contentsOf: fileURL)
//      let url = Bundle.main.url(forResource: "song", withExtension: "mp3")
      player = try AVAudioPlayer(data: soundData)
      player.prepareToPlay()
    } catch let error as NSError {
      print("Failed to init audio player: \(error)")
    }
  }
  
  func setupRemoteTransportControls() {
    // Get the shared MPRemoteCommandCenter
    let commandCenter = MPRemoteCommandCenter.shared()
    
    // Add handler for Play Command
    commandCenter.playCommand.addTarget { [unowned self] event in
      print("Play command - is playing: \(self.player.isPlaying)")
      if !self.player.isPlaying {
        self.play()
        return .success
      }
      return .commandFailed
    }
    
    // Add handler for Pause Command
    commandCenter.pauseCommand.addTarget { [unowned self] event in
      print("Pause command - is playing: \(self.player.isPlaying)")
      if self.player.isPlaying {
        self.pause()
        return .success
      }
      return .commandFailed
    }
  }
  
  func setupNowPlaying() {
    // Define Now Playing Info
    var nowPlayingInfo = [String : Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = "Addin's Podcast"
    
    if let image = UIImage(named: "deen") {
      nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
        return image
      }
    }
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
    
    // Set the metadata
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
  
  func updateNowPlaying(isPause: Bool) {
    // Define Now Playing Info
    var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
    
    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1
    
    // Set the metadata
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }

}




