//
//  ReportViewController.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 16/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Cocoa

class ReportViewController: NSViewController {
    
    var fileManager: FileManager?
    var successController: reportTableController?
    var failureController: reportTableController?

    @IBOutlet weak var successTable: NSTableView!
    @IBOutlet weak var failureTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.successController = reportTableController(files: fileManager!.successFiles!)
        self.failureController = reportTableController(files: fileManager!.failedFiles!)
        
        successTable.setDelegate(successController)
        successTable.setDataSource(successController)
        successTable.reloadData()
        
        failureTable.setDelegate(failureController)
        failureTable.setDataSource(failureController)
        failureTable.reloadData()
    }
    
}

class reportTableController: NSObject {
    
    var files: [Metadata] = []
    
    init(files: [Metadata]) {
        self.files = files
    }
}

extension reportTableController: NSTableViewDelegate {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.files.count
    }
}

extension reportTableController: NSTableViewDataSource {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = (tableView.makeViewWithIdentifier("FileID", owner: ContainerViewController.self) as? NSTableCellView) else {
            return nil
        }
        
        cell.textField?.stringValue = self.files[row].name
        cell.imageView?.image = self.files[row].icon
        
        return cell
    }
}