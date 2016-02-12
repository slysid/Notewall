//
//  FileHandler.swift
//  Pinwall
//
//  Created by Bharath on 31/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit


class FileHandler {
    
    static let sharedHandler = FileHandler()
    
    init() {
        
        
    }
    
    func writeToFileWithData(data:NSDictionary?,filename:NSString) {
        
        
        let sourcePath:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        let filePath = sourcePath.stringByAppendingPathComponent(filename as String).stringByAppendingString(".plist")
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) == false {
            
            let plistPath = NSBundle.mainBundle().pathForResource(filename as String, ofType: "plist")
            
            do {
                
                try NSFileManager.defaultManager().copyItemAtPath(plistPath!, toPath: filePath)
            }
            catch {
                
                print("Not able to move the plist file")
            }
            
        }
        
        data!.writeToFile(filePath, atomically: false)

    }

    func fetchDataFromFile(filename:String) -> NSMutableDictionary? {

        let sourcePath:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first!
        let filePath = sourcePath.stringByAppendingPathComponent(filename).stringByAppendingString(".plist")
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) == false {
            
            let plistPath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
            
            do {
                
                try NSFileManager.defaultManager().copyItemAtPath(plistPath!, toPath: filePath)
            }
            catch {
                
                print("Not able to move the plist file")
            }
            
        }
        
        let returnData = NSMutableDictionary(contentsOfFile: filePath)
        
        return returnData
    }
    
}
