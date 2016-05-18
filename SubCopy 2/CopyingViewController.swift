//
//  CopyingViewController.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 16/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Cocoa

class CopyingViewController: NSViewController {
    
    var passedData: (String, [String: Int])?
    var fileManager: FileManager?
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        (self.parentViewController! as! ContainerViewController).copyingViewController = self
        
        spinner.startAnimation(nil)
    }
    
    override func viewDidAppear() {
        guard let data = passedData else {
            return
        }
        
        self.fileManager!.copyTo(data.0, filetypes: data.1, progressIndicator: progressIndicator) {
            (successFiles, failedFiles) in
            self.fileManager!.successFiles = successFiles
            self.fileManager!.failedFiles = failedFiles
            self.performSegueWithIdentifier("reportSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        guard let dest = segue.destinationController as? ReportViewController else {
            return
        }
        
        dest.fileManager = self.fileManager
    }
}
