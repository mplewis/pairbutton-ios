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
    var fileName: String
    var fileDir: String

    init(fileUrl: NSURL) {
        self.fileUrl = fileUrl
        self.fileName = fileUrl.lastPathComponent
        self.fileDir = fileUrl.path!.stringByDeletingLastPathComponent
    }
    
}
