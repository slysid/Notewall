//
//  ProfileController.swift
//  Pin!t
//
//  Created by Bharath on 08/04/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class ProfileController:UIViewController,ProfileViewProtocolDelegate {
    
    var viewRect:CGRect?
    var profileView:ProfileView?
    
    init(frame:CGRect) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewRect = frame
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        self.view = UIView(frame:self.viewRect!)
        
    }
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.redColor()
        
        if (self.profileView == nil) {
            
            self.profileView = ProfileView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
            self.profileView!.profileViewDelegate = self
            
            self.view.addSubview(profileView!)
            
        }
    }
    
    
    // PROFILEVIEW DELEGATE METHODS
    
    
    func updateScreenName(name: String, completion: (Bool,String) -> Void) {
        
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        let data = ["ownerid" : ownerId,"screenname":name]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathUpdateScreenName , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (result == true) {
                
                let errMsg = response.objectForKey("data")!.objectForKey("error")
                
                if(errMsg != nil) {
                    
                    let msg = response["data"]!["error"] as? String
                    if (msg!.rangeOfString("duplicate") != nil) {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: "ScreenName Exists", startTimer: true)
                    }
                    
                    completion(false,msg!)
                }
                else {
                    
                    Common.sharedCommon.config!["screenname"] = name
                    completion(true,"OK")
                }
                
                
            }
            else {
                
                completion(false,"Unknown Error")
            }
        }
        
    }
    
    func updatePassword(oldpassword: String, newpassword: String, completion: (Bool, String) -> Void) {
        
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        let data = ["ownerid" : ownerId,"oldpassword":oldpassword,"newpassword":newpassword]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathUpdatePaswword, body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            
            if (result == true) {
                
                let errMsg = response.objectForKey("data")!.objectForKey("error")
                
                if(errMsg != nil) {
                    
                    let msg = response["data"]!["error"] as? String
                    completion(false,msg!)
                }
                else {
                    
                    completion(true,"OK")
                }
            }
            else {
                
                completion(false,"Unknown Error")
            }
        }
        
    }
}
