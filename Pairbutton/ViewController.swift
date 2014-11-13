//
//  ViewController.swift
//  Pairbutton
//
//  Created by Matthew Lewis on 11/12/14.
//  Copyright (c) 2014 Kestrel Development. All rights reserved.
//

import Cocoa

let colNames: [NSString] = ["filename", "directory"]

let mySampleFiles = [
    ["filey", "/Users/mplewis/files"],
    ["filier", "/Users/mplewis/files"],
    ["my_script.py", "/Users/mplewis/projectsync/python"]
]

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var watchedFileList: NSScrollView!
    @IBOutlet weak var removeFileButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return mySampleFiles.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn colObj: NSTableColumn?, row: Int) -> AnyObject? {
        if let ident: NSString = colObj?.identifier {
            for (col, colName: NSString) in enumerate(colNames) {
                if colName.isEqualToString(ident) {
                    return mySampleFiles[row][col]
                }
            }
        }
        return nil
    }

    @IBAction func addFile(sender: AnyObject) {
        let openDialog = NSOpenPanel()
        openDialog.canChooseFiles = true
        openDialog.canChooseDirectories = false
        openDialog.canCreateDirectories = false
        openDialog.allowsMultipleSelection = true
        let window = self.view.window!
        openDialog.beginSheetModalForWindow(window) { clicked in
            if clicked == NSFileHandlingPanelOKButton {
                for url in openDialog.URLs {
                    if let u = url as? NSURL {
                        let file = WatchedFile(fileUrl: u)
                        println("\(file.fileName), \(file.fileDir)")
                    }
                }
            }
        }
    }
    
    @IBAction func removeFile(sender: AnyObject) {
    }

}

