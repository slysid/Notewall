//
//  LoginViewController.swift
//  Pinwall
//
//  Created by Bharath on 01/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit


class LoginViewController:UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,CloseViewProtocolDelegate,UITextFieldDelegate {
    
    var googleSignButton:UIImageView?
    var fbSignInButton:UIImageView?
    var mailSignInButton:UIImageView?
    var userName:CustomTextField?
    var password:CustomTextField?
    var closeButton:CloseView?
    var activity:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        
        self.view!.backgroundColor = UIColor.blackColor()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let bgImage = UIImageView(frame: self.view.frame)
        bgImage.image = UIImage(named: kDefaultBGImageName)
        self.view.addSubview(bgImage)
        
        let buttonWidth:CGFloat = Common.sharedCommon.calculateDimensionForDevice(50)
        
        googleSignButton = UIImageView(frame: CGRectMake(0,0,buttonWidth,buttonWidth))
        googleSignButton!.center = CGPointMake(kScreenWidth * 0.5, kScreenHeight * 0.5)
        googleSignButton!.image = UIImage(named: "google.png")
        self.view!.addSubview(googleSignButton!)
        googleSignButton!.userInteractionEnabled = true
        let gtap = UITapGestureRecognizer(target: self, action: "gButtonTapped")
        googleSignButton!.addGestureRecognizer(gtap)
        
        fbSignInButton = UIImageView(frame: CGRectMake(0, 0, buttonWidth, buttonWidth))
        fbSignInButton!.center = CGPointMake(kScreenWidth * 0.5 - (2 * buttonWidth) - Common.sharedCommon.calculateDimensionForDevice(20) , kScreenHeight * 0.5)
        fbSignInButton!.image = UIImage(named: "fb.png")
        self.view!.addSubview(fbSignInButton!)
        fbSignInButton!.userInteractionEnabled = true
        let ftap = UITapGestureRecognizer(target: self, action: "fbButtonTapped")
        fbSignInButton!.addGestureRecognizer(ftap)
        
        mailSignInButton = UIImageView(frame: CGRectMake(0, 0, buttonWidth, buttonWidth))
        mailSignInButton!.center = CGPointMake(kScreenWidth * 0.5 + (2 * buttonWidth) + Common.sharedCommon.calculateDimensionForDevice(20) , kScreenHeight * 0.5)
        mailSignInButton!.image = UIImage(named: "mail.png")
        self.view!.addSubview(mailSignInButton!)
        mailSignInButton!.userInteractionEnabled = true
        let mtap = UITapGestureRecognizer(target: self, action: "mailButtonTapped")
        mailSignInButton!.addGestureRecognizer(mtap)
        
    }
    
    
    // TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (validateInput() == true) {
            
            textField.resignFirstResponder()
            
            let email = self.userName!.text!
            let pass = self.password!.text!
            
            self.startAnimating()
            self.validateAndRegisterLogin(email, pass: pass, loggedInMode: kLoggedinThroughMail)
            
            return true
        }
        
        return false
    }
    
    //Custom Methods
    
    func startAnimating() {
        
        if (activity == nil) {
            
            activity = UIActivityIndicatorView(frame: CGRectMake(0,0,40,40))
            activity!.center = CGPointMake(kScreenWidth * 0.5, kScreenHeight * 0.75)
            self.view!.addSubview(activity!)
        }
        
        
        
        if (self.activity != nil) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.activity!.startAnimating()
            })
        }
    }
    
    func stopAnimating() {
        
        if (self.activity != nil) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.activity!.stopAnimating()
                self.activity!.hidden = true
                self.activity!.removeFromSuperview()
                self.activity = nil
            })
        }
       
    }
    
    func validateInput() -> Bool {
        
        var emailResult:Bool = true
        var passwordResult:Bool = true
        
        let userNameRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", userNameRegex)
        emailResult = emailTest.evaluateWithObject(userName!.text)
        
        if (password!.text == "") {
            
            passwordResult = false
        }
        
        
        return emailResult && passwordResult
    }
    
    func gButtonTapped() {
        
        Common.sharedCommon.config!["loggedInMode"] = kLoggedinThroughGoogle
        self.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func fbButtonTapped() {
        
        
    }
    
    func mailButtonTapped() {
        
        
        googleSignButton!.alpha = 0.0
        mailSignInButton!.alpha = 0.0
        fbSignInButton!.alpha = 0.0
        
        if (userName == nil) {
            
            userName = CustomTextField(frame: CGRectMake(0,0,kLoginTextFieldWidth,Common.sharedCommon.calculateDimensionForDevice(40)))
            userName!.center = CGPointMake(kScreenWidth * 0.5, Common.sharedCommon.calculateDimensionForDevice(20) + userName!.frame.size.height * 0.5)
            userName!.placeholder = "email"
            userName!.delegate = self
        }
        
        if (password == nil) {
            
            password = CustomTextField(frame: userName!.frame)
            password!.center = CGPointMake(userName!.center.x, userName!.center.y + userName!.frame.size.height + Common.sharedCommon.calculateDimensionForDevice(20))
            password!.secureTextEntry = true
            password!.placeholder = "password"
            password!.delegate = self
        }
        
        if (closeButton == nil) {
            
            closeButton = CloseView(frame: CGRectMake(kScreenWidth - Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
            closeButton!.closeViewDelegate = self
        }
        
        self.view.addSubview(userName!)
        self.view.addSubview(password!)
        self.view.addSubview(closeButton!)
        
        self.userName!.becomeFirstResponder()
    }
    
    
    
    func validateAndRegisterLogin(email:String,pass:String?,loggedInMode:String) {
        
        var data:NSDictionary?
        
        if (pass != nil) {
            
            data = NSDictionary(objects: [email,pass!], forKeys: ["email","password"])
        }
        else {
            
            data = NSDictionary(objects: [email], forKeys: ["email"])
        }
        
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathRegister, body: data!, replace: nil) { (result, response) -> Void in
            
            if (self.activity != nil) {
                
                self.stopAnimating()
                
            }
            
            if(result == true) {
                
                let respData = response["data"]!
                
                if (respData.objectForKey("error") == nil) {
                    
                    self.handleCloseViewTap()
                    
                    let ownerId = respData["ownerid"] as! String
                    self.setConfigurationForSuccessfulLogin(loggedInMode, email: email, ownerid: ownerId)
                    
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        
                        
                    })
                }
                else {
                    
                    let error = respData["error"] as! String
                    
                   /* let alert = UIAlertController(title: "ERROR", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    let alertOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        
                         alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                            
                         })
                        
                    })
                    alert.addAction(alertOK)
                    self.presentViewController(alert, animated: true, completion: { () -> Void in
                        
                    }) */
                    
                    Common.sharedCommon.showMessageViewWithMessage(self, message: error)
                }
                
            }
            else {
                
                if (Common.sharedCommon.config?["loggedInMode"] as? String == kLoggedinThroughGoogle ) {
                    
                        Common.sharedCommon.config!["loggedInMode"] = kLoggedInYetToLogin
                        GIDSignIn.sharedInstance().signOut()

                }
                
                Common.sharedCommon.showMessageViewWithMessage(self, message: "Network Error")
                
            }
        }
        
    }
    
    func setConfigurationForSuccessfulLogin(loggedInMode:String,email:String,ownerid:String) {
        
        Common.sharedCommon.config!["loggedInMode"] = loggedInMode
        Common.sharedCommon.config!["ownerId"] = ownerid
        Common.sharedCommon.config!["email"] = email
        Common.sharedCommon.config!["isLoggedIn"] = true
        Common.sharedCommon.config!["loggedinDate"] = NSDate()
        
         FileHandler.sharedHandler.writeToFileWithData(Common.sharedCommon.config!, filename: "Config")
        
    }
    
    // CloseView Delegate Methods
    
    func handleCloseViewTap() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if self.userName != nil {
                
                self.userName!.removeFromSuperview()
                self.password!.removeFromSuperview()
                self.closeButton!.removeFromSuperview()
                
                if (self.activity != nil) {
                    self.activity!.stopAnimating()
                    self.activity!.removeFromSuperview()
                    self.activity = nil
                }
                
                self.userName = nil
                self.password = nil
                self.closeButton = nil
                
            }
            
            self.googleSignButton!.alpha = 1.0
            self.fbSignInButton!.alpha = 1.0
            self.mailSignInButton!.alpha = 1.0
            
        }
       
    }
    
    
    // GOOGLE Delegate methods
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if (error == nil) {
            
            self.validateAndRegisterLogin(user.profile.email, pass: nil, loggedInMode: kLoggedinThroughGoogle)
            
        }
        else {
            
            self.stopAnimating()
            Common.sharedCommon.config!["loggedInMode"] = kLoggedInYetToLogin
            Common.sharedCommon.showMessageViewWithMessage(self, message: "Google Authentication Error")
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
        
    }

}
