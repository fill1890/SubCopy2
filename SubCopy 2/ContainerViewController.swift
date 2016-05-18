//
//  ContainerViewController.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 16/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Cocoa

class ContainerViewController: NSViewController {
    
    var initialViewController: InitialViewController?
    var copyingViewController: CopyingViewController?
    var reportViewController: ReportViewController?
    var mainStoryboard: NSStoryboard?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        
        self.initialViewController = self.mainStoryboard!.instantiateControllerWithIdentifier("initialViewController") as? InitialViewController
        
        self.addChildViewController(self.initialViewController!)
        self.view.addSubview(self.initialViewController!.view)
        
        let attributes = [NSLayoutAttribute.CenterY, NSLayoutAttribute.Width, NSLayoutAttribute.Height]
        
        let sourceConstraints = attributes.map() {
            (attribute) in
            return NSLayoutConstraint(item: self.initialViewController!.view, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: attribute, multiplier: 1, constant: 0)
        }
        
        NSLayoutConstraint.activateConstraints(sourceConstraints)
        
        
    }
}
