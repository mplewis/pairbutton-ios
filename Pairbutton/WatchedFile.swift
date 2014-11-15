//
//  WatchedFile.swift
//  Pairbutton
//
//  Created by Matthew Lewis on 11/13/14.
//  Copyright (c) 2014 Kestrel Development. All rights reserved.
//

import Cocoa

class WatchedFile: NSObject, VDKQueueDelegate {
    
    var fileUrl: NSURL
    var onFirstRead: ((initialData: NSData) -> ())?
    var onDelta: ((delta: NSData) -> ())?
    var vq: VDKQueue

    init(fileUrl: NSURL, onFirstRead: ((initialData: NSData) -> ())?, onDelta: ((delta: NSData) -> ())? ) {
        self.fileUrl = fileUrl
        self.onFirstRead = onFirstRead
        self.onDelta = onDelta
        self.vq = VDKQueue()
        super.init()
        vq.addPath(fileUrl.path!)
        vq.delegate = self
    }
    
    func queue(queue: VDKQueue!, didReceiveNotification notificationName: String!, forPath fpath: String!) {
        println(fpath, notificationName)
        if notificationName == "VDKQueueFileDeletedNotification" {
            vq.removeAllPaths()
            vq.addPath(fileUrl.path!)
        }
    }
    
    func fileName() -> NSString {
        return fileUrl.lastPathComponent
    }
    
    func fileDir() -> NSString {
        return fileUrl.path!.stringByDeletingLastPathComponent
    }
    
}
