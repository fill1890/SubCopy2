//
//  ViewController.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 2/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var sourceValidateTimer: TimerWithReset? = nil
    var destValidateTimer: TimerWithReset? = nil
    var fileManager: FileManager? = nil
    var checkBoxStates: Dictionary = [String: Int]()
    var sourceValid: Bool = false
    var destValid: Bool = false
    var MasterFileManager : NSFileManager = NSFileManager()
    var hasFocus: Bool = true
    var reportViewController: PopoverViewController? = nil
    var reportPanel: NSWindow? = nil
    var reportPopover: NSPopover? = nil
    
    @IBOutlet weak var sourceField: NSTextField!
    @IBOutlet weak var destField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var extSpinner: NSProgressIndicator!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var copyProgress: NSProgressIndicator!
    @IBOutlet weak var copyOverlay: NSProgressIndicator!
    @IBOutlet weak var statusButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.copyOverlay.doubleValue = 100.0
        self.copyOverlay.alphaValue = 0
        
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)
        
        self.reportViewController = self.storyboard?.instantiateControllerWithIdentifier("PopoverViewController") as? PopoverViewController
        self.addChildViewController(self.reportViewController!)
        
        let reportFrame: NSRect = self.reportViewController!.view.bounds
        let reportStyle: Int = NSTitledWindowMask + NSClosableWindowMask
        let reportRect: NSRect = NSWindow.contentRectForFrameRect(reportFrame, styleMask: reportStyle)
        self.reportPanel = NSWindow(contentRect: reportRect, styleMask: reportStyle, backing: NSBackingStoreType.Buffered, defer: true)
        self.reportPanel?.contentViewController = self.reportViewController
        self.reportPanel?.releasedWhenClosed = false
        
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
                    
                    self.sourceValid = false
                    
                    self.setupCopy()
                    
                }
                
            }
            
        }
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
        
        _ = TimerWithReset(time: 1500) {
            self.representedObject = NSURL.fileURLWithPath(newVal, isDirectory: true)
        }
        
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
    
    func createReport(callback: (Void -> Void)?) {
        self.reportViewController?.setupReport(fileManager!)
        
        if self.reportPopover == nil {
            self.reportPopover = NSPopover()
            self.reportPopover!.contentViewController = self.reportViewController
            //self.reportPopover!.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            self.reportPopover!.animates = true
            self.reportPopover!.behavior = NSPopoverBehavior.Transient
            self.reportPopover!.delegate = self
        }
        
        if callback != nil {
            callback!()
        }
        
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
    
    @IBAction func copyFiles(sender: AnyObject?) {
        copyProgress.doubleValue = 0.0
        copyOverlay.alphaValue = 0.0
        
        fileManager?.copyTo(self.destField.stringValue, filetypes: checkBoxStates, progressIndicator: copyProgress) {
            (successFiles, failedFiles) in
            
            self.fileManager?.failedFiles = failedFiles
            self.fileManager?.successFiles = successFiles
            
            self.copyOverlay.alphaValue = 1.0
            
            self.statusButton.title = "\(successFiles.count) copied, \(failedFiles.count) failures"
            self.statusButton.hidden = false
            
            if !self.hasFocus {
                let notification = NSUserNotification()
                notification.title = "Copy Complete"
                notification.informativeText = "\(successFiles.count) files copied successfully, \(failedFiles.count) failed"
                notification.soundName = NSUserNotificationDefaultSoundName
                
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
            }
        }
    }
    
    @IBAction func showReport(sender: AnyObject?) {
        if self.reportPanel!.visible {
            self.reportPanel!.makeKeyAndOrderFront(self)
            return
        }
        
        guard sender != nil else {
            return;
        }
        
        self.createReport() {
        
            let prefEdge: NSRectEdge = NSRectEdge.MaxX
        
            self.reportPopover!.showRelativeToRect(self.statusButton.bounds, ofView: sender! as! NSView, preferredEdge: prefEdge)
            
        }
        
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return fileManager?.filetypes.count ?? 0
    }
}

extension ViewController : NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let checkState: Int = NSOnState
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = fileManager?.filetypes[row] else {
            return nil
        }
        
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

extension ViewController: NSPopoverDelegate {
    func detachableWindowForPopover(popover: NSPopover) -> NSWindow? {
        return self.reportPanel
    }
    
    /*func popoverShouldClose(popover: NSPopover) -> Bool {
        <#code#>
    }
    
    func popoverWillShow(notification: NSNotification) {
        <#code#>
    }
    
    func popoverDidShow(notification: NSNotification) {
        <#code#>
    }
    
    func popoverWillClose(notification: NSNotification) {
        <#code#>
    }*/
    
    func popoverDidClose(notification: NSNotification) {
        self.reportPopover = nil
    }
    
    func popoverShouldDetach(popover: NSPopover) -> Bool {
        return true
    }
}

class NSTableCellViewWithCheckBox: NSTableCellView {
    @IBOutlet var checkBox: NSButton?
}