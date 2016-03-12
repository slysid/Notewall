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
            
            completion(true,"cahce ignoreed")
        }
        else {
            
            let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathPoll , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
                
                if (result == true) {
                    
                    let err:String? = response.objectForKey("data")?.objectForKey("error") as? String
                    
                    if (err == nil) {
                        
                        let resultCount = response["data"]!["count"] as? Int
                        
                        if (resultCount == 0) {
                            
                            completion(true,"")
                        }
                        else if (resultCount == self.allNotesDataList.count) {
                            
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
}
