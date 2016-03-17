//
//  CacheManager.swift
//  Pinwall
//
//  Created by Bharath on 27/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class CacheManager:NSObject {
    
    static let sharedCacheManager = CacheManager()
    var allNotesDataList:Array<Dictionary<String,AnyObject>> = []
    var myNotesDataList:Array<Dictionary<String,AnyObject>> = []
    var myFavsNotesDataList:Array<Dictionary<String,AnyObject>> = []
    var selectedOwnerNotesDataList:Array<Dictionary<String,AnyObject>> = []
    
    override init() {
        
        
    }
    
    func decideOnCall(ignoreCache:Bool, completion:(Bool,String)->()) {
        
        if (ignoreCache == true) {
            
            completion(true,"cache ignoreed")
        }
        else {
            
            let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathPoll , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
                
                if (result == true) {
                    
                    let err:String? = response.objectForKey("data")?.objectForKey("error") as? String
                    
                    if (err == nil) {
                        
                        let resultCount = response["data"]!["count"] as? Int
                        
                        if (resultCount == self.allNotesDataList.count && resultCount != 0) {
                            
                            completion(false,"")
                        }
                        else {
                            
                            completion(true,"")
                        }
                        
                    }
                    else {
                        
                        let errMsg = response["data"]!["error"] as! String
                        completion(false,errMsg)
                        
                    }
                    
                }
                else {
                    
                    
                    completion(true,"API Call Failed")
                }
            }
        }
    }
    
    func filterResults() {
        
        let ownerid = Common.sharedCommon.config!["ownerId"] as! String
        
        let onlyOwnerPredicate = NSPredicate(format: "ownerID = %@", ownerid)
        self.myNotesDataList = ((self.allNotesDataList as NSArray).filteredArrayUsingPredicate(onlyOwnerPredicate) as? Array<Dictionary<String,AnyObject>>)!
        
        let onlyOwnerFavPredicate = NSPredicate(format: "owners contains[c] %@", ownerid)
        self.myFavsNotesDataList = ((self.allNotesDataList as NSArray).filteredArrayUsingPredicate(onlyOwnerFavPredicate) as? Array<Dictionary<String,AnyObject>>)!
        
    }
    
    
    func removeNoteFromCache(note:WallNote) {
        
        let index = self.allNotesDataList.indexOf({$0["noteID"] as! String == note.stickyNoteID!})
        self.allNotesDataList.removeAtIndex(index!)
        
        self.filterResults()
        
    }
    
    func addNoteToCache(note:WallNote) {
        
        
    }
    
    
    func replaceWallNote(note:WallNote,key:String,value:AnyObject?) {
        
        let index = self.allNotesDataList.indexOf({$0["noteID"] as! String == note.stickyNoteID!})
        var tempNote = self.allNotesDataList[index!]
        tempNote[key] = value
        self.allNotesDataList[index!] = tempNote
        
        self.filterResults()
    }
    
    func clearCache() {
        
        self.allNotesDataList.removeAll()
        self.myNotesDataList.removeAll()
        self.myFavsNotesDataList.removeAll()
        self.selectedOwnerNotesDataList.removeAll()
        
    }
    
}
