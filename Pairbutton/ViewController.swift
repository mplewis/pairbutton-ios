//
//  ViewController.swift
//  Pairbutton
//
//  Created by Matthew Lewis on 11/12/14.
//  Copyright (c) 2014 Kestrel Development. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var watchedFiles = [WatchedFile]()
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var watchedFileList: NSScrollView!
    @IBOutlet weak var removeFileButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return watchedFiles.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn colObj: NSTableColumn?, row: Int) -> AnyObject? {
        if let colName: NSString = colObj?.identifier {
            let file = watchedFiles[row]
            if colName.isEqualToString("filename") {
                return file.fileName()
            } else if colName.isEqualToString("directory") {
                return file.fileDir()
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
                        let file = WatchedFile(fileUrl: u, onFirstRead: nil, onDelta: nil)
                        self.watchedFiles.append(file)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func removeFile(sender: AnyObject) {
        let selected = tableView.selectedRowIndexes
        for i in 0...watchedFiles.count {
            let j = watchedFiles.count - i
            if selected.containsIndex(j) {
                watchedFiles.removeAtIndex(j)
            }
        }
        tableView.reloadData()
    }

}

