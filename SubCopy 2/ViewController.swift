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
    
    @IBOutlet weak var sourceField: NSTextField!
    @IBOutlet weak var destField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var extSpinner: NSProgressIndicator!
    @IBOutlet weak var copyButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSControlTextDidChangeNotification, object: sourceField, queue: NSOperationQueue.mainQueue(), usingBlock: {
            (notification) in
            if self.sourceValidateTimer == nil {
                self.sourceValidateTimer = TimerWithReset(time: 1500, callback: self.validateSource)
            }
            
            self.sourceValidateTimer!.reset()
            
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSControlTextDidChangeNotification, object: destField, queue: NSOperationQueue.mainQueue(), usingBlock: {
            (notification) in
            if self.destValidateTimer == nil {
                self.destValidateTimer = TimerWithReset(time: 1500, callback: self.validateDest)
            }
            
            self.destValidateTimer!.reset()
            
        })
        
    }

    override var representedObject: AnyObject? {
        didSet {
        
            fileManager = FileManager(folder: self.representedObject! as! NSURL)
            tableView.reloadData()
            
            extSpinner.stopAnimation(nil)
            
            setupCopy()
            
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
        sourceValid = true
        
        extSpinner.startAnimation(nil)
        
        _ = TimerWithReset(time: 1500, callback: {
            self.representedObject = NSURL.fileURLWithPath(newVal, isDirectory: true)
        })
        
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
            
            // openPanel.URL: URL for file
            
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
            
            // openPanel.URL: URL for file
            
            self.destField.stringValue = openPanel.URL!.path!
            
            self.validateDest()
            
        }
    }
    
    @IBAction func copyFiles(sender: AnyObject?) {
        for file in fileManager!.files {
            if file.isDirectory == false {
                let src = file.url
                let rawDestPath = destField.stringValue
                let destPath = rawDestPath.characters.last == "/" ? rawDestPath : rawDestPath + "/"
                let dest = NSURL.fileURLWithPath(destPath + file.name, isDirectory: false)
                do {
                    try MasterFileManager.copyItemAtURL(src, toURL: dest)
                } catch {
                    print("Unable to copy file: \(file.url)")
                }
            }
        }
    }
}

class TimerWithReset: NSObject {
    var time: Int = 1500
    var timer: NSTimer? = nil
    var callback: (() -> Void)? = nil
    
    init(time: Int?, callback: () -> Void) {
        super.init()
        self.time = time ?? 1500
        self.callback = callback
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(TimerWithReset.finish), userInfo: nil, repeats: true)
    }
    
    func reset() {
        self.timer!.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(TimerWithReset.finish), userInfo: nil, repeats: true)
    }
    
    func finish() {
        self.time -= 500
        if self.time <= 0 {
            self.timer!.invalidate()
            self.callback!()
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
        
        //var image: NSImage?
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
                //cell.imageView?.image = image ?? nil
                
                checkBoxStates[item["name"]!] = checkState
                
                cell.checkBox!.bind("value", toObject: (checkBoxStates as NSDictionary), withKeyPath: item["name"]!, options: nil)
                
                return cell
            }

        } else if tableColumn == tableView.tableColumns[1] {
            //image = item.name.icon
            text = item["name"]!
            cellIdentifier = "FiletypeCellID"
        }
        
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            //cell.imageView?.image = image ?? nil
            return cell
        }
        
        return nil
    }
}

class NSTableCellViewWithCheckBox: NSTableCellView {
    @IBOutlet var checkBox: NSButton?
}

