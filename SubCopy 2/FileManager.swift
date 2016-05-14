//
//  FileManager.swift
//  SubCopy 2
//
//  Created by Andrew Walls on 2/05/2016.
//  Copyright © 2016 Andrew Walls. All rights reserved.
//

import Foundation
import AppKit

struct Metadata {
    let url: NSURL
    let name: String
    let filetype: String
    let icon: NSImage
    let isDirectory: Bool
    
    init(url: NSURL, name: String, filetype: String, icon: NSImage, isDirectory: Bool) {
        self.url = url
        self.name = name
        self.filetype = filetype
        self.icon = icon
        self.isDirectory = isDirectory
    }
}

struct FileManager {
    var filetypes: [Dictionary] = [[String: String]]()
    var foundFileTypes: [String] = []
    var files: [Metadata] = []
    var successFiles: [Metadata]? = nil
    var failedFiles: [Metadata]? = nil
    
    init (folder: NSURL) {
        let keys: [String] = [NSURLIsDirectoryKey, NSURLNameKey, NSURLEffectiveIconKey]
        
        let fileManager = NSFileManager()
        let enumerator = fileManager.enumeratorAtURL(
            folder,
            includingPropertiesForKeys: keys,
            options: [.SkipsHiddenFiles, .SkipsPackageDescendants],
            errorHandler: nil
        )
        
        while let url = enumerator?.nextObject() as? NSURL {
            
            do {
                let properties = try url.resourceValuesForKeys(keys)
                
                let file = Metadata(
                    url: url,
                    name: properties[NSURLNameKey] as? String ?? "",
                    filetype: url.pathExtension ?? "(none)",
                    icon: properties[NSURLEffectiveIconKey] as? NSImage ?? NSImage(),
                    isDirectory: properties[NSURLIsDirectoryKey]! as! Bool ? true : false
                )
                
                files.append(file)
                
                if !foundFileTypes.contains(file.filetype) && !file.isDirectory {
                    filetypes.append(["name": file.filetype])
                    foundFileTypes.append(file.filetype)
                }
                
            } catch {
                print("Error reading file attributes")
            }
            
        }
        
    }
    
    mutating func copyTo(dest: String, filetypes: [String: Int], progressIndicator: NSProgressIndicator?, callback: (([Metadata], [Metadata]) -> Void)?) {
        // Copy files
        // Update progress indicator
        // Store successful files
        // Store failed files
        
        let canUpdateProgress = progressIndicator != nil
        let MasterFileManager = NSFileManager()
        self.successFiles = []
        self.failedFiles = []
        
        dispatch_async(GlobalUtilityQueue) {
            let files = self.files.count
            for i in 0..<files {
                let file = self.files[i]
                
                if canUpdateProgress {
                
                    dispatch_async(GlobalMainQueue) {
                        
                        progressIndicator!.doubleValue = (Double(i) + 1) / Double(files) * 100
                        
                    }
                    
                }
                
                if file.isDirectory == false && filetypes[file.filetype] == 1 {
                    let src = file.url
                    let rawDestPath = dest
                    let destPath = rawDestPath.characters.last == "/" ? rawDestPath : rawDestPath + "/"
                    let dest = NSURL.fileURLWithPath(destPath + file.name, isDirectory: false)
                    do {
                        try MasterFileManager.copyItemAtURL(src, toURL: dest)
                        self.successFiles!.append(file)
                    } catch {
                        //print("Unable to copy file: \(file.url)")
                        self.failedFiles!.append(file)
                    }
                }
            }
            
            dispatch_async(GlobalMainQueue) {
                
                if canUpdateProgress {
                    progressIndicator!.doubleValue = 100.0
                }
                
                if callback != nil {
                    callback!(self.successFiles!, self.failedFiles!)
                }
                
            }
            
        }
        
    }
    
}