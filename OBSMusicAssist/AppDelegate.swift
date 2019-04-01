//
//  AppDelegate.swift
//  OBSMusicAssist
//
//  Created by Maxwell Hubbard on 3/30/19.
//  Copyright © 2019 Maxwell Hubbard. All rights reserved.
//

import Cocoa
import AppleScriptObjC


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    @objc dynamic var trackName: NSString!
    @objc dynamic var trackArtist: NSString!
    @objc dynamic var trackAlbum: NSString!
    
    @objc dynamic var trackDuration: NSNumber!

    @objc dynamic var playerState: PlayerState = .unknown
    
    // AppleScriptObjC object for communicating with iTunes
    var iTunesBridge: iTunesBridge
    
    override init() {
        // AppleScriptObjC setup
        Bundle.main.loadAppleScriptObjectiveCScripts()
        
        // create an instance of iTunesBridge script object for Swift code to use
        let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
        self.iTunesBridge = iTunesBridgeClass.alloc() as! iTunesBridge
        // general application setup
      
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // iTunes emits track change notifications; very handy for UI refreshes
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    

}

