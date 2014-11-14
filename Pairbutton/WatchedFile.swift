//
//  WatchedFile.swift
//  Pairbutton
//
//  Created by Matthew Lewis on 11/13/14.
//  Copyright (c) 2014 Kestrel Development. All rights reserved.
//

import Cocoa

class WatchedFile: NSObject {
    
    var fileUrl: NSURL
    var onDelta: ((delta: NSData) -> ())?

    init(fileUrl: NSURL, onFirstRead: ((initialData: NSData) -> ())?, onDelta: ((delta: NSData) -> ())? ) {
        self.fileUrl = fileUrl
        let task = NSTask()
        let stdOut = NSPipe()
        task.launchPath = "/usr/bin/python"
        let scriptPath = NSBundle.mainBundle().pathForResource("watch_file", ofType: "py")!
        task.arguments = [scriptPath, "alpha", "bravo", "charlie"]
        let handler: (NSFileHandle!) -> Void = { handle in
            let data = handle.availableData
            let dataStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println("---");
            println(dataStr);
        }
        stdOut.fileHandleForReading.readabilityHandler = handler
        let onExit: (NSTask!) -> Void = { task in
            task.standardOutput.fileHandleForReading.readabilityHandler = nil
        }
        task.terminationHandler = onExit
        task.standardInput = NSPipe()
        task.standardOutput = stdOut
        task.launch()
    }
    
    func fileName() -> NSString {
        return fileUrl.lastPathComponent
    }
    
    func fileDir() -> NSString {
        return fileUrl.path!.stringByDeletingLastPathComponent
    }
    
}
