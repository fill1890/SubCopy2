//
//  PopoverViewController.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 11/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
    
    @IBOutlet var successTable: NSTableView!
    @IBOutlet var failureTable: NSTableView!
    
    var successController: reportViewController?
    var failureController: reportViewController?
    
    func setupReport(fileManager: FileManager) {
        guard let successFiles = fileManager.successFiles else {
            return
        }
        
        guard let failureFiles = fileManager.failedFiles else {
            return
        }
        
        self.successController = reportViewController(files: successFiles)
        self.failureController = reportViewController(files: failureFiles)
        
        successTable.setDelegate(successController)
        successTable.setDataSource(successController)
        successTable.reloadData()
        
        failureTable.setDelegate(failureController)
        failureTable.setDataSource(failureController)
        failureTable.reloadData()
        
    }
}

class reportViewController: NSObject {
    
    var files: [Metadata] = []
    
    init(files: [Metadata]) {
        self.files = files
    }
}

extension reportViewController: NSTableViewDelegate {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.files.count
    }
}

extension reportViewController: NSTableViewDataSource {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = (tableView.makeViewWithIdentifier("FileID", owner: ViewController.self) as? NSTableCellView) else {
            return nil
        }
        
        cell.textField?.stringValue = self.files[row].name
        
        return cell
    }
}