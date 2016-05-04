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
    
}