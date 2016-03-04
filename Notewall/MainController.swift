//
//  MainController.swift
//  Notewall
//
//  Created by Bharath on 21/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit


class MainController:UIViewController,NoteWallProtocolDelegate {
    
    var loginController:LoginViewController?
    var notewallController:NotewallController?
    
    override func viewDidLoad() {
        
        self.view!.backgroundColor = UIColor.whiteColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.checkAgeAndDecideOnApplication()
        
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    //NoteWall Delegate Methods
    
    func handleLogout() {
        
        if (Common.sharedCommon.config!["loggedInMode"] as! String == kLoggedinThroughGoogle) {
            
            GIDSignIn.sharedInstance().signOut()
        }
        
        Common.sharedCommon.config!["loggedInMode"] = kLoggedInYetToLogin
        Common.sharedCommon.config!["ownerId"] = ""
        Common.sharedCommon.config!["email"] = ""
        Common.sharedCommon.config![kKeyRegisterStatus] = ""
        Common.sharedCommon.config!["isLoggedIn"] = false
        Common.sharedCommon.config!["loggedinDate"] = ""
        Common.sharedCommon.config![kKeyPolaroid] = nil
        Common.sharedCommon.config!["isFirstLogin"] = false
        
        FileHandler.sharedHandler.writeToFileWithData(Common.sharedCommon.config!, filename: "Config")
        
        let topViewController = UIApplication.sharedApplication().windows[0].rootViewController
        topViewController!.dismissViewControllerAnimated(false) { () -> Void in
            
            self.notewallController = nil
        }
    }
    
    
    // Custom Methods
    
    func checkAgeAndDecideOnApplication() {
        
        if (Common.sharedCommon.config!["isLoggedIn"]!.boolValue == true) {
            
            if (Common.sharedCommon.config?[kKeyRegisterStatus ] as? String == kAllowedRegisterStatus[kRegisterStatuses.kConfirmed.hashValue]) {
                
                self.signInApplication()
            }
            else {
                
                self.presentLoginView()
            }
            
            
           /* if(Common.sharedCommon.ageOfApplication() < kTimeoutApp) {
                
                self.signInApplication()
            }
            else {
                
                self.handleLogout()
            } */
        }
        else {
            
            self.presentLoginView()
        }
    }
    
    func checkAgeAndSignOut() {
        
        if(Common.sharedCommon.ageOfApplication() > kTimeoutApp) {
            
            self.handleLogout()
        }
    }
    
    func presentLoginView() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if (self.loginController == nil) {
                
                self.loginController = LoginViewController()
            }
            
            self.presentViewController(self.loginController!, animated: false, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    func signInApplication() {
        
        if (self.notewallController == nil) {
            
            self.notewallController = NotewallController()
            self.notewallController!.noteWallDelegate = self
        }
        
        self.presentViewController(self.notewallController!, animated: false) { () -> Void in
            
            
        }
    }
    
    
   /* func signOutApplication() {
        
        GIDSignIn.sharedInstance().signOut()
        
        //self.presentLoginView()
        
        let topViewController = UIApplication.sharedApplication().windows[0].rootViewController
        topViewController!.dismissViewControllerAnimated(false) { () -> Void in
            
        }
        
    } */
    
    
}
