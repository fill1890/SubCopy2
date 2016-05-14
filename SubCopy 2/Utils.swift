//
//  Utils.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 6/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Foundation

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
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
