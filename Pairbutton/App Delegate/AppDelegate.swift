//
//  AppDelegate.swift
//  Pairbutton
//
//  Created by Matthew Lewis on 11/12/14.
//  Copyright (c) 2014 Kestrel Development. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainVC: ViewController?
    
    func applicationWillTerminate(aNotification: NSNotification) {
        mainVC?.appExiting()
    }
    
}

