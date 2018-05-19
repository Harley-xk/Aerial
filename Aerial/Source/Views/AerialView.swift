//
//  AerialView.swift
//  Aerial
//
//  Created by John Coates on 10/22/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

import Foundation
import ScreenSaver
import AVFoundation
import AVKit

@objc(AerialView)
class AerialView: ScreenSaverView {
    var preferencesController: PreferencesWindowController?
    
    lazy var playerV2: AerialPlayer = {
        return PlayerManager.player(forView: self)
    }()
    
    // MARK: - Init / Setup
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        self.animationTimeInterval = 1.0 / 30.0
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setupPlayerLayer(withPlayer player: AerialPlayer) {
        let layer = CALayer()
        self.layer = layer
        wantsLayer = true
        layer.backgroundColor = NSColor.black.cgColor
        layer.needsDisplayOnBoundsChange = true
        layer.frame = self.bounds
        
        debugLog("setting up player layer with frame: \(self.bounds) / \(self.frame)")
        
        let playerLayer = player.newLayer()
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        playerLayer.frame = layer.bounds
        layer.addSublayer(playerLayer)
    }
    
    func setup() {
        playerV2 = PlayerManager.player(forView: self)
        
        setupPlayerLayer(withPlayer: playerV2)
        
        ManifestLoader.instance.addCallback { videos in
            self.playerV2.playNextVideo()
        }
    }
    
    // MARK: - Preferences
    
    func hasConfigureSheet() -> Bool {
        return true
    }
    
    func configureSheet() -> NSWindow? {
        if let controller = preferencesController {
            return controller.window
        }
        
        let controller = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindow"))
    
        preferencesController = controller
        return controller.window
    }
}
