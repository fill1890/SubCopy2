//
//  ViewController.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 2/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Cocoa

class InitialViewController: NSViewController {
    
    var sourceValidateTimer: TimerWithReset? = nil
    var destValidateTimer: TimerWithReset? = nil
    var checkBoxStates: Dictionary = [String: Int]()
    var sourceValid: Bool = false
    var destValid: Bool = false
    var MasterFileManager : NSFileManager = NSFileManager()
    var hasFocus: Bool = true
    var fileManager: FileManager?
    
    @IBOutlet weak var sourceField: NSTextField!
    @IBOutlet weak var destField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var extSpinner: NSProgressIndicator!
    @IBOutlet weak var copyButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSControlTextDidChangeNotification, object: sourceField, queue: NSOperationQueue.mainQueue()) {
            (notification) in
            if self.sourceValidateTimer == nil {
                self.sourceValidateTimer = TimerWithReset(time: 1500, callback: self.validateSource)
            }
            
            self.sourceValidateTimer!.reset()
            
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSControlTextDidChangeNotification, object: destField, queue: NSOperationQueue.mainQueue()) {
            (notification) in
            if self.destValidateTimer == nil {
                self.destValidateTimer = TimerWithReset(time: 1500, callback: self.validateDest)
            }
            
            self.destValidateTimer!.reset()
            
        }

    }
    
    override func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidResignMainNotification, object: self.view.window!, queue: NSOperationQueue.mainQueue()) {
            (notification) in
            self.hasFocus = false
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidBecomeMainNotification, object: self.view.window!, queue: NSOperationQueue.mainQueue()) {
            (notification) in
            self.hasFocus = true
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        
            dispatch_async(GlobalUtilityQueue) {
                
                self.fileManager = FileManager(folder: self.representedObject! as! NSURL)
                
                dispatch_async(GlobalMainQueue) {
                    
                    self.tableView.reloadData()
                    
                    self.extSpinner.stopAnimation(nil)
                    
                    self.sourceValid = true
                    
                    self.setupCopy()
                    
                }
                
            }
            
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        guard let segue = segue as? SlideViewLeftSegue else {
            return
        }
        
        guard let destination = segue.destinationController as? CopyingViewController else {
            return
        }
        
        destination.passedData = (self.destField.stringValue, self.checkBoxStates)
        destination.fileManager = self.fileManager
        
    }
    
    func validateSource() {
        let newVal = sourceField.stringValue
        var isDir: ObjCBool = false
        
        let present = MasterFileManager.fileExistsAtPath(newVal, isDirectory: &isDir)
        
        guard present && isDir else {
            sourceField.textColor = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
            sourceValid = false
            setupCopy()
            return
        }
        
        sourceField.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        extSpinner.startAnimation(nil)
        
        self.representedObject = NSURL.fileURLWithPath(newVal, isDirectory: true)
        
    }
    
    func validateDest() {
        let newVal = destField.stringValue
        var isDir: ObjCBool = false
        
        let present = MasterFileManager.fileExistsAtPath(newVal, isDirectory: &isDir)
        
        guard present && isDir else {
            destField.textColor = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
            destValid = false
            setupCopy()
            return
        }
        
        destField.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1)
        destValid = true
        
        setupCopy()
        
    }
    
    func setupCopy() {
        if destValid && sourceValid {
            copyButton.enabled = true
        } else {
            copyButton.enabled = false
        }
    }
    
    func updateCheckBox(sender sender: AnyObject?) {
        guard sender != nil else {
            print("Warning: Sender not given")
            return
        }
        
        let button = sender! as! NSButton
        
        guard button.identifier !=  nil else {
            print("Checkbox could not be identified")
            return
        }
        
        checkBoxStates[button.identifier!] = button.state
    }

    @IBAction func openSourceDocument(sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        
        openPanel.beginSheetModalForWindow(self.view.window!) {
            (response) in
            
            guard response == NSFileHandlingPanelOKButton else {
                return
            }
            
            self.sourceField.stringValue = openPanel.URL!.path!
            
            self.validateSource()
            
        }
    }
    
    @IBAction func openDestDocument(sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        
        openPanel.beginSheetModalForWindow(self.view.window!) {
            (response) in
            
            guard response == NSFileHandlingPanelOKButton else {
                return
            }
            
            self.destField.stringValue = openPanel.URL!.path!
            
            self.validateDest()
            
        }
    }
}

extension InitialViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.fileManager?.filetypes.count ?? 0
    }
}

extension InitialViewController: NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let checkState: Int = NSOnState
        var text: String = ""
        var cellIdentifier: String = ""
        
        let item = self.fileManager!.filetypes[row]
    
        if tableColumn == tableView.tableColumns[0] {
            text = ""
            
            if let cell = tableView.makeViewWithIdentifier("CheckCellID", owner: nil) as? NSTableCellViewWithCheckBox {
                
                cell.textField?.stringValue = text
                
                cell.checkBox!.identifier = item["name"]!
                cell.checkBox!.target = self
                cell.checkBox!.action = #selector(updateCheckBox)
                cell.checkBox!.state = checkState
                
                checkBoxStates[item["name"]!] = checkState
                
                return cell
            }

        } else if tableColumn == tableView.tableColumns[1] {
            text = item["name"]!
            cellIdentifier = "FiletypeCellID"
        }
        
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.textField?.backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
            return cell
        }
        
        return nil
    }
}

class NSTableCellViewWithCheckBox: NSTableCellView {
    @IBOutlet var checkBox: NSButton?
}