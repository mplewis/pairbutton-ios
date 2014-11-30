//
//  ViewController.swift
//  Pairbutton
//
//  Created by Matthew Lewis on 11/12/14.
//  Copyright (c) 2014 Kestrel Development. All rights reserved.
//

import Cocoa

let baseUrl = "http://localhost:5000"

let authKeyHeaderName = "Auth-Key"

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: baseUrl))
    let serializer = AFJSONRequestSerializer()
    
    var watchedFiles: [WatchedFile] = [] {
        didSet {
            var plural = "s"
            if watchedFiles.count == 1 {
                plural = ""
            }
            statusLabel.stringValue = "Sharing \(watchedFiles.count) file\(plural)."
        }
    }
    var watchedFileIds: [NSURL: Int] = [:]
    var channelId: Int?
    var channelKey: String? {
        didSet {
            if let k = channelKey {
                serializer.setValue(k, forHTTPHeaderField: authKeyHeaderName)
            } else {
                serializer.setValue(nil, forHTTPHeaderField: authKeyHeaderName)
            }
        }
    }
    var channelName: String? {
        didSet {
            if channelName != nil {
                shareLinkLabel.stringValue = "Share this link: \(baseUrl)/\(channelName!)"
            }
        }
    }
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var shareLinkLabel: NSTextField!
    @IBOutlet weak var watchedFileList: NSScrollView!
    @IBOutlet weak var removeFileButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.requestSerializer = serializer
        manager.POST("/channel", parameters: nil, success: { _, resp in
            if let r = resp as? NSDictionary {
                println(r)
                if let id = resp["id"] as? String {
                    self.channelId = id.toInt()
                }
                if let key = resp["key"] as? String {
                    self.channelKey = key
                }
                if let name = resp["name"] as? String {
                    self.channelName = name
                }
            }
        }, failure: { _, err in
            println(err)
        })
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
            if clicked != NSFileHandlingPanelOKButton {
                return
            }
            for url in openDialog.URLs {
                if let u = url as? NSURL {
                    if let channelId = self.channelId {
                        let file = WatchedFile(fileUrl: u, onFirstRead: { (initialData) -> () in
                            let params = ["name": u.lastPathComponent, "data": initialData]
                            self.manager.POST("/channel/\(channelId)/file", parameters: params, success: { (_, resp) -> Void in
                                println(resp)
                                if let idStr = resp["id"] as? String {
                                    self.watchedFileIds[u] = idStr.toInt()
                                }
                            }, failure: { (_, err) -> Void in
                                println(err)
                            })
                        }, onDelta: { (delta, expected_hash) -> () in
                            let params = ["file_delta": delta, "expected_hash": expected_hash]
                            if let fileId = self.watchedFileIds[u] {
                                self.manager.PUT("/channel/\(channelId)/file/\(fileId)", parameters: params, success: nil, failure: { (_, err) -> Void in
                                    if let u = err.userInfo {
                                        println(u["data"])
                                    }
                                })
                            }
                        })
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
                let file = watchedFiles.removeAtIndex(j)
                if let fileId = self.watchedFileIds[file.fileUrl] {
                    if let channelId = self.channelId {
                        println(channelId, fileId)
                        self.manager.DELETE("/channel/\(channelId)/file/\(fileId)", parameters: nil, success: { (_, resp) -> Void in
                            println("Deleted: \(file.fileName())")
                        }, failure: { (_, err) -> Void in
                            if let u = err.userInfo {
                                println(u["data"])
                            }
                        })
                    }
                }
            }
        }
        tableView.reloadData()
    }

}

