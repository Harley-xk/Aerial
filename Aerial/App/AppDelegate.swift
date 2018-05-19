//
//  AppDelegate.swift
//  Aerial Test
//
//  Created by John Coates on 10/23/15.
//  Copyright © 2015 John Coates. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        let objects = objectsFromNib(loadNibNamed: "PreferencesWindow")
        
        guard let windowIndex = objects.index(where: { $0 is NSWindow }),
            let preferencesWindow = objects[windowIndex] as? NSWindow
            else {
                fatalError("Missing window object")
        }
        
        setUp(preferencesWindow: preferencesWindow)
    }
    
    private let preferencesWindowController = PreferencesWindowController()
    
    private func setUp(preferencesWindow window: NSWindow) {
        window.makeKeyAndOrderFront(self)
        window.styleMask = [
            .titled,
            .closable,
            .miniaturizable
        ]
        
        var frame = window.frame
        frame.origin = window.frame.origin
        window.setFrame(frame, display: true)
    }
    
    private func objectsFromNib(loadNibNamed nibName: String) -> [AnyObject] {
        let bundle = Bundle.main
        var topLevelObjects: NSArray? = NSArray()
        bundle.loadNibNamed(NSNib.Name(rawValue: nibName),
                            owner: preferencesWindowController,
                            topLevelObjects: &topLevelObjects)
        return topLevelObjects?.map{$0 as AnyObject} ?? []
    }
}
