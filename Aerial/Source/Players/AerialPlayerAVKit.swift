//
//  AerialPlayerAVKit.swift
//  Aerial
//
//  Created by John Coates on 9/15/17.
//  Copyright © 2017 John Coates. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

private class LayerHolder {
    weak var layer: AVPlayerLayer?
    
    init(layer: AVPlayerLayer) {
        self.layer = layer
    }
}

@objc class AerialPlayerAVKit: NSObject, AerialPlayer {
    private var player = AVPlayer()
    private var layerHolders = [LayerHolder]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func newLayer() -> CALayer {
        let layer = AVPlayerLayer(player: self.player)
        if #available(OSX 10.10, *) {
            layer.videoGravity = .resizeAspectFill
        }
        
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        let layerHolder = LayerHolder(layer: layer)
        layerHolders.append(layerHolder)
        return layer
    }
    
    weak var delegate: AerialPlayerDelegate?
    var videoURL: URL?
    
    func play() {
        player.play()
    }
    
    func playNextVideo() {
        guard let video = ManifestLoader.instance.randomVideo() else {
            return
        }
        
        play(URL: video.url)
    }
    
    func play(URL: URL) {
        player = AVPlayer()
        
        layerHolders = layerHolders.filter { $0.layer != nil }
        
        for layerHolder in layerHolders {
            guard let layer = layerHolder.layer else {
                continue
            }
            
            layer.player = player
        }
        
        let asset = CachedOrCachingAsset(URL)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        player.actionAtItemEnd = .none
        
        subscribeToNotifications(for: item)
        
        if player.rate == 0 {
            player.play()
        }
    }
    
    func pause() {
        player.pause()
    }
    
    private func subscribeToNotifications(for item: AVPlayerItem) {
        let notificationCenter = NotificationCenter.default
        
        // remove old entries
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(self,
                                       selector: .playerItemFailedtoPlayToEnd,
                                       name: .AVPlayerItemFailedToPlayToEndTime,
                                       object: item)
        notificationCenter.addObserver(self,
                                       selector: .playerItemNewErrorLogEntry,
                                       name: .AVPlayerItemNewErrorLogEntry,
                                       object: item)
        notificationCenter.addObserver(self,
                                       selector: .playerItemPlaybackStalled,
                                       name: .AVPlayerItemPlaybackStalled,
                                       object: item)
        notificationCenter.addObserver(self,
                                       selector: .playerItemDidReachEnd,
                                       name: .AVPlayerItemDidPlayToEndTime,
                                       object: item)
    }
    
    // MARK: - AVPlayerItem Notifications
    
    @objc func playerItemFailedtoPlayToEnd(notification: Notification) {
        NSLog("AVPlayerItemFailedToPlayToEndTimeNotification \(notification)")
        
        playNextVideo()
    }
    
    @objc func playerItemNewErrorLogEntry(notification: Notification) {
        NSLog("AVPlayerItemNewErrorLogEntryNotification \(notification)")
    }
    
    @objc func playerItemPlaybackStalled(notification: Notification) {
        NSLog("AVPlayerItemPlaybackStalledNotification \(notification)")
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        debugLog("played did reach end")
        debugLog("notification: \(notification)")
        playNextVideo()
        
        debugLog("playing next video for player \(String(describing: player))")
    }
}

// MARK: - Selector Extension

private typealias LocalClass = AerialPlayerAVKit

private extension Selector {
    static let playerItemFailedtoPlayToEnd = #selector(LocalClass.playerItemFailedtoPlayToEnd)
    static let playerItemNewErrorLogEntry = #selector(LocalClass.playerItemNewErrorLogEntry)
    static let playerItemPlaybackStalled = #selector(LocalClass.playerItemPlaybackStalled)
    static let playerItemDidReachEnd = #selector(LocalClass.playerItemDidReachEnd)
}
    
