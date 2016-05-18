//
//  StoryboardSegues.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 16/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Foundation
import AppKit

class SlideViewLeftSegue: NSStoryboardSegue {
    
    override init(identifier: String?, source sourceController: AnyObject, destination destinationController: AnyObject) {
        var myIdentifier = ""
        if identifier == nil {
            myIdentifier = ""
        } else {
            myIdentifier = identifier!
        }
        
        super.init(identifier: myIdentifier, source: sourceController, destination: destinationController)
    }
    
    override func perform() {
        let sourceController = self.sourceController as! NSViewController
        let destinationController = self.destinationController as! NSViewController
        let containerViewController = self.sourceController.parentViewController! as! ContainerViewController
        
        containerViewController.addChildViewController(destinationController)
        
        containerViewController.view.wantsLayer = true
        sourceController.view.wantsLayer = true
        destinationController.view.wantsLayer = true
        
        containerViewController.transitionFromViewController(sourceController, toViewController: destinationController, options: NSViewControllerTransitionOptions.SlideLeft, completionHandler: nil)
        
        
    }
    
}