//
//  ViewController.swift
//  Media Player
//
//  Created by Mac HD  on 03/03/21.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {

    var player = AVAudioPlayer()
    @IBOutlet weak var img: UIImageView!
    
    
    let url = Bundle.main.url(forResource: "music", withExtension: "mp3")
    var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupPlayer()
        setupNowPlaying()
        player.play()
        commandCenterSetup()
        img.layer.cornerRadius = img.frame.height / 5
        
    }

    func setUpAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print(error.localizedDescription)
        }
    }
    func setupPlayer() {
        guard let url = url else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.delegate = self
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupNowPlaying() {
        guard let url = url else { return }
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        
        let title = "K Bgm ringtone"
        let album = "Spark tones"
        let artist = " $HARON "
        let image = UIImage(named: "albumImg") ?? UIImage()
        let artWork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
            return image
        }
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artWork
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1.0)
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value:duration.seconds)
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    let commandCenter = MPRemoteCommandCenter.shared()
    
    func commandCenterSetup() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        setupNowPlaying()
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.setupNowPlaying()
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.setupNowPlaying()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            let seconds = 0.0
            let time = CMTime(seconds: seconds, preferredTimescale: 1000)
            
            self.player.currentTime = TimeInterval(time.seconds)
            self.setupNowPlaying()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.setupNowPlaying()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
            let time = CMTime(seconds: seconds, preferredTimescale: 1000)
            self.player.currentTime = TimeInterval(time.seconds)
            return .success
        }
    }
    
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finish")
        self.setupNowPlaying()
    }
}
