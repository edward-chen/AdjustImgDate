//
//  AppDelegate.swift
//  AdjustImgDate
//
//  Created by ChenYi-Hung on 2016/4/27.
//  Copyright © 2016年 ChenYi-Hung. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationOpenUntitledFile(sender: NSApplication) -> Bool {
        return true;
    }

}

