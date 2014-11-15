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
    var lastContents: NSString
    var onFirstRead: ((initialData: NSData) -> ())?
    var onDelta: ((delta: NSData) -> ())?
    var vq: VDKQueue

    init(fileUrl: NSURL, onFirstRead: ((initialData: NSData) -> ())?, onDelta: ((delta: NSData) -> ())? ) {
        self.fileUrl = fileUrl
        var error: NSError?
        self.lastContents = String(contentsOfURL: fileUrl, encoding: NSUTF8StringEncoding, error: &error)!
        if (error != nil) {
            println(error)
        }
        self.onFirstRead = onFirstRead
        self.onDelta = onDelta
        self.vq = VDKQueue()
        super.init()
        vq.addPath(fileUrl.path!)
        vq.delegate = self
    }
    
    func queue(queue: VDKQueue!, didReceiveNotification notificationName: String!, forPath fpath: String!) {
        if notificationName == "VDKQueueFileDeletedNotification" {
            vq.removeAllPaths()
            vq.addPath(fileUrl.path!)
        } else if notificationName == "VDKQueueFileAttributesChangedNotification" {
            var error: NSError?
            if let newContents = String(contentsOfURL: fileUrl, encoding: NSUTF8StringEncoding, error: &error) {
                if self.lastContents == newContents {
                    return
                }
                let dmp = DiffMatchPatch()
                let patches = dmp.patch_makeFromOldString(self.lastContents, andNewString: newContents)
                println(dmp.patch_toText(patches))
                self.lastContents = newContents
            } else {
                println(error)
            }
        }
    }
    
    func fileName() -> NSString {
        return fileUrl.lastPathComponent
    }
    
    func fileDir() -> NSString {
        return fileUrl.path!.stringByDeletingLastPathComponent
    }
    
}
