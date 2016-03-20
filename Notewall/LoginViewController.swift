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
    var screenName:CustomTextField?
    var userName:CustomTextField?
    var password:CustomTextField?
    var closeButton:CloseView?
    var resendEmail:CustomButton?
    var activity:UIActivityIndicatorView?
    var fbVerticalConstraint:[NSLayoutConstraint]?
    var googleVerticalConstraint:[NSLayoutConstraint]?
    var emailVerticalConstraint:[NSLayoutConstraint]?
    var horizontalConstraint:[NSLayoutConstraint]?
    var tutorialView:TutorialView?
    var orientationOffset:CGFloat = 60.0
    var socialEmail:String?
    
    override func viewDidLoad() {
        
        self.view!.backgroundColor = UIColor.blackColor()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let bgImage = UIImageView(frame: self.view.frame)
        bgImage.image = UIImage(named: kDefaultBGImageName)
        bgImage.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        self.view.addSubview(bgImage)
        
        googleSignButton = UIImageView()
        googleSignButton!.translatesAutoresizingMaskIntoConstraints = false
        googleSignButton!.image = UIImage(named: "google.png")
        self.view!.addSubview(googleSignButton!)
        googleSignButton!.userInteractionEnabled = true
        let gtap = UITapGestureRecognizer(target: self, action: "gButtonTapped")
        googleSignButton!.addGestureRecognizer(gtap)
        
        fbSignInButton = UIImageView()
        fbSignInButton!.translatesAutoresizingMaskIntoConstraints = false
        fbSignInButton!.image = UIImage(named: "fb.png")
        self.view!.addSubview(fbSignInButton!)
        fbSignInButton!.userInteractionEnabled = true
        let ftap = UITapGestureRecognizer(target: self, action: "fbButtonTapped")
        fbSignInButton!.addGestureRecognizer(ftap)
        
        mailSignInButton = UIImageView()
        mailSignInButton!.translatesAutoresizingMaskIntoConstraints = false
        mailSignInButton!.image = UIImage(named: "mail.png")
        self.view!.addSubview(mailSignInButton!)
        mailSignInButton!.userInteractionEnabled = true
        let mtap = UITapGestureRecognizer(target: self, action: "mailButtonTapped:")
        mailSignInButton!.addGestureRecognizer(mtap)
        
        
        resendEmail = CustomButton(frame: CGRectMake(0,0,200,50), buttonTitle: "Resend Email", normalColor: UIColor.whiteColor(), highlightColor: UIColor.blackColor())
        resendEmail?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.25)
        resendEmail?.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(.FlexibleTopMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        resendEmail!.backgroundColor = UIColor.clearColor()
        resendEmail!.alpha = 0.0
        resendEmail!.addTarget(self, action: "resendConfirmationEmail", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(resendEmail!)
        
        self.calculateConstraints()
        
        if (Common.sharedCommon.config?[kKeyRegisterStatus ] as? String == kAllowedRegisterStatus[kRegisterStatuses.kAwaiting.hashValue]) {
            
           /* dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Awaiting registation confirmation", startTimer:true)
            }) */
            
        }
        else if (Common.sharedCommon.config!["isFirstLogin"] as! Bool == true) {
            
            self.performSelector("showTutorialView", withObject: nil, afterDelay: 1.0)
            
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            
            
            }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
                self.calculateConstraints()
                
        }
        
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait) {
            
            if (screenName != nil) {
                
                screenName!.center = CGPointMake(screenName!.center.x,screenName!.center.y + orientationOffset)
            }
            
            if (userName != nil) {
                
                userName!.center = CGPointMake(userName!.center.x,userName!.center.y + orientationOffset)
            }
            
            if (password != nil) {
                
                password!.center = CGPointMake(password!.center.x,password!.center.y + orientationOffset)
            }
            
           
        }
        else {
            
            if (screenName != nil) {
                
                screenName!.center = CGPointMake(screenName!.center.x,screenName!.center.y - orientationOffset)
            }
            
            if (userName != nil) {
                
                userName!.center = CGPointMake(userName!.center.x,userName!.center.y - orientationOffset)
            }
            
            if (password != nil) {
                
                password!.center = CGPointMake(password!.center.x,password!.center.y - orientationOffset)
            }

        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        Common.sharedCommon.invalidateTimerAndRemoveMessage()
    }
    
    func calculateConstraints() {
        
        let buttonWidth:CGFloat = Common.sharedCommon.calculateDimensionForDevice(60)
        
        let views:[String:UIImageView] = Dictionary(dictionaryLiteral: ("fb",fbSignInButton!),("google",googleSignButton!),("email",mailSignInButton!))
        let metrics = ["dim" : buttonWidth,
            "horizontalPadding" : (UIScreen.mainScreen().bounds.width - (3 * buttonWidth)) / 4,
            "verticalPadding" : (UIScreen.mainScreen().bounds.height * 0.5) - (buttonWidth * 0.5)]
        
        
        if let fvertical = fbVerticalConstraint, let gvertical = googleVerticalConstraint, let mvertical = emailVerticalConstraint, let horizontal = horizontalConstraint  {
            
            NSLayoutConstraint.deactivateConstraints(fvertical)
            NSLayoutConstraint.deactivateConstraints(gvertical)
            NSLayoutConstraint.deactivateConstraints(mvertical)
            NSLayoutConstraint.deactivateConstraints(horizontal)
        }
        
        fbVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalPadding-[fb(dim)]", options:[] , metrics: metrics, views: views)
        googleVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalPadding-[google(dim)]", options:[] , metrics: metrics, views: views)
        emailVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalPadding-[email(dim)]", options:[] , metrics: metrics, views: views)
        
        horizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-horizontalPadding-[fb(dim)]-horizontalPadding-[google(dim)]-horizontalPadding-[email(dim)]", options:[] , metrics: metrics, views: views)
        
        NSLayoutConstraint.activateConstraints(fbVerticalConstraint!)
        NSLayoutConstraint.activateConstraints(googleVerticalConstraint!)
        NSLayoutConstraint.activateConstraints(emailVerticalConstraint!)
        NSLayoutConstraint.activateConstraints(horizontalConstraint!)
        
    }
    
    
    func resendConfirmationEmail() {
        
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        var data = [String:AnyObject]()
        data = ["ownerid" : ownerID as String]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathResendMail , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (result == true) {
                
                let err:String? = response.objectForKey("data")?.objectForKey("error") as? String
                
                if (err == nil) {
                    
                    Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Mail Sent", startTimer: true)
                    
                }
                else {
                    
                    if err!.rangeOfString("Quota") != nil {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.resendEmail!.alpha = 0.0
                            
                        })
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Too many emails sent", startTimer: true)
                    }
                    else {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: err!, startTimer: true)
                    }
                }
                
            }
            else {
                
                
            }
        }
    }
    
    
    // TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (validateInput() == true) {
            
            var email:String?
            var pass:String?
            var name:String?
    
            textField.resignFirstResponder()
            
            if (userName != nil) {
                
                email = self.userName!.text!
            }
            
            if (Common.sharedCommon.config!["loggedInMode"] as? String == kLoggedinThroughGoogle) {
                
                email = self.socialEmail!
            }
            
            if (password != nil ){
                
                pass = self.password!.text!
            }
            else {
                
                pass = nil
            }
            
            if (screenName != nil) {
                
                name = self.screenName!.text!
                
                if (name == "") {
                    
                    name = nil
                }
                
            }
            
            
            self.startAnimating()
            self.validateAndRegisterLogin(email!, pass: pass, name:name, loggedInMode: kLoggedinThroughMail)
            
            return true
        }
        
        return false
    }
    
    //Custom Methods
    
    func showTutorialView() {
        
        self.tutorialView = TutorialView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
        self.tutorialView?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 2.0)
        self.view.addSubview(self.tutorialView!)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                
                
                    self.tutorialView?.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.5)
                
                }, completion: { (Bool) -> Void in
                
            })
        }
        
    }
    
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
        var screenNameResult:Bool = true
        
        let userNameRegex = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", userNameRegex)
        
        if (userName != nil) {
            
            emailResult = emailTest.evaluateWithObject(userName!.text)
        }
        
        
        if (password != nil) {
            
            if (password!.text == "") {
                
                passwordResult = false
            }
            
        }
        
        if (Common.sharedCommon.config!["loggedInMode"] as? String == kLoggedinThroughGoogle) {
            
            if (screenName != nil) {
                
                if (screenName!.text == "") {
                    
                    screenNameResult = false
                }
            }
        }
        
        return emailResult && passwordResult && screenNameResult
    }
    
    func gButtonTapped() {
        
        Common.sharedCommon.config!["loggedInMode"] = kLoggedinThroughGoogle
        self.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func fbButtonTapped() {
        
        
    }
    
    func mailButtonTapped(sender:AnyObject?) {
       
        var showAll = true
        
        if (sender is UITapGestureRecognizer == false) {
            
            showAll = false
            
        }
        
        let loginTextFieldWidth:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.75
        
        if (screenName == nil) {
            
            screenName = CustomTextField(frame: CGRectMake(0,0,loginTextFieldWidth,Common.sharedCommon.calculateDimensionForDevice(40)))
            screenName!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin .union(.FlexibleRightMargin).union(.FlexibleBottomMargin).union(.FlexibleWidth)
            screenName!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, Common.sharedCommon.calculateDimensionForDevice(20) + screenName!.frame.size.height * 0.5)
            screenName!.placeholder = "screen name"
            screenName!.delegate = self
            
            if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait) {
                
                screenName!.center = CGPointMake(screenName!.center.x,screenName!.center.y + orientationOffset)
            }
            
            self.view.addSubview(screenName!)
        }
        
        
         self.screenName!.becomeFirstResponder()
        
        if (showAll == true) {
            
            googleSignButton!.alpha = 0.0
            mailSignInButton!.alpha = 0.0
            fbSignInButton!.alpha = 0.0
            
            if (userName == nil) {
                
                userName = CustomTextField(frame: screenName!.frame)
                userName!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin .union(.FlexibleRightMargin).union(.FlexibleBottomMargin).union(.FlexibleWidth)
                userName!.center = CGPointMake(screenName!.center.x, screenName!.center.y + screenName!.frame.size.height + Common.sharedCommon.calculateDimensionForDevice(10))
                userName!.placeholder = "email"
                userName!.delegate = self
            }
            
            if (password == nil) {
                
                password = CustomTextField(frame: userName!.frame)
                password!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin .union(.FlexibleRightMargin).union(.FlexibleBottomMargin).union(.FlexibleWidth)
                password!.center = CGPointMake(userName!.center.x, userName!.center.y + userName!.frame.size.height + Common.sharedCommon.calculateDimensionForDevice(10))
                password!.secureTextEntry = true
                password!.placeholder = "password"
                password!.delegate = self
            }
            
            
            if (closeButton == nil) {
                
                closeButton = CloseView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
                closeButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin .union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
                closeButton!.closeViewDelegate = self
            }
            
            
            self.view.addSubview(userName!)
            self.view.addSubview(password!)
            self.view.addSubview(closeButton!)
            self.userName!.becomeFirstResponder()
        }
        
        
        
    }
    
    
    
    func validateAndRegisterLogin(email:String,pass:String?,name:String?,loggedInMode:String) {
        
        var data:NSDictionary?
        
        if (pass != nil && name != nil) {
            
            data = NSDictionary(objects: [email,pass!,name!], forKeys: ["email","password","screenname"])
        }
        else if (pass != nil && name == nil) {
            
            data = NSDictionary(objects: [email,pass!], forKeys: ["email","password"])
        }
        else if (name != nil) {
            
            data = NSDictionary(objects: [email,name!], forKeys: ["email","screenname"])
        }
        else {
            
            data = NSDictionary(objects: [email], forKeys: ["email"])
        }
        
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathRegister, body: data!, replace: nil,requestContentType:kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (self.activity != nil) {
                
                self.stopAnimating()
                
            }
            
            if(result == true) {
                
                let respData = response["data"]!
                
                if (respData.objectForKey("error") == nil) {
                    
                    
                    /*let ownerId = respData["ownerid"] as! String
                    let screenName = respData["screenname"] as! String */
                    let registerStatus = respData[kKeyRegisterStatus] as! String
                    
                    self.setConfigurationForSuccessfulLogin(loggedInMode, email: email, response:respData as! Dictionary<String, AnyObject>)
                    
                    if registerStatus == kAllowedRegisterStatus[kRegisterStatuses.kConfirmed.hashValue] {
                        
                        self.handleCloseViewTap()
                        dispatch_async(dispatch_get_main_queue() , { () -> Void in
                            
                            self.dismissViewControllerAnimated(false, completion: { () -> Void in
                                
                                
                            })
                        })
                    }
                    else {
                        
                        dispatch_async(dispatch_get_main_queue() , { () -> Void in
                            
                            self.screenName?.alpha = 0.0
                            self.resendEmail!.alpha = 1.0
                        })
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Awaiting registration confirmation", startTimer:true)
                        
                    }
                    
                    
                }
                else {
                    
                    let error = respData["error"] as! String
                    
                    if (error == kSocialScreenName) {
                        
                        dispatch_async(dispatch_get_main_queue() , { () -> Void in
                            
                            self.mailButtonTapped("social")
                        })
                        
                    }
                    else {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: error,startTimer:true)
                    }
                    
                }
                
            }
            else {
                
                if (Common.sharedCommon.config?["loggedInMode"] as? String == kLoggedinThroughGoogle ) {
                    
                        Common.sharedCommon.config!["loggedInMode"] = kLoggedInYetToLogin
                        GIDSignIn.sharedInstance().signOut()

                }
                
                Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Network Error", startTimer:true)
                
            }
        }
        
    }
    
    /*func setConfigurationForSuccessfulLogin(loggedInMode:String,email:String,ownerid:String,screenname:String,registerstatus:String) {
        
        Common.sharedCommon.config!["loggedInMode"] = loggedInMode
        Common.sharedCommon.config!["ownerId"] = ownerid
        Common.sharedCommon.config!["screenname"] = screenname
        Common.sharedCommon.config![kKeyRegisterStatus] = registerstatus
        Common.sharedCommon.config!["email"] = email
        Common.sharedCommon.config!["isLoggedIn"] = true
        Common.sharedCommon.config!["loggedinDate"] = NSDate()
        Common.sharedCommon.config![kKeyPolaroid] = nil
        Common.sharedCommon.config!["isFirstLogin"] = false
        
         FileHandler.sharedHandler.writeToFileWithData(Common.sharedCommon.config!, filename: "Config")
        
    }*/
    
    func setConfigurationForSuccessfulLogin(loggedInMode:String, email: String, response:Dictionary<String,AnyObject>) {
        
        print(response)
        
        self.resendEmail!.alpha = 0.0
        
        Common.sharedCommon.config!["loggedInMode"] = loggedInMode
        Common.sharedCommon.config!["ownerId"] = response["ownerid"] as! String
        Common.sharedCommon.config!["screenname"] = response["screenname"] as! String
        Common.sharedCommon.config!["token"] = response["token"] as! String
        Common.sharedCommon.config![kKeyRegisterStatus] = response["registerstatus"] as! String
        Common.sharedCommon.config!["email"] = email
        Common.sharedCommon.config!["isLoggedIn"] = true
        Common.sharedCommon.config!["loggedinDate"] = NSDate()
        Common.sharedCommon.config![kKeyPolaroid] = nil
        Common.sharedCommon.config!["isFirstLogin"] = false
        
        FileHandler.sharedHandler.writeToFileWithData(Common.sharedCommon.config!, filename: "Config")
        
    }
    
    // CloseView Delegate Methods
    
    func handleCloseViewTap() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if self.screenName != nil {
                
                self.screenName!.removeFromSuperview()
                self.screenName = nil
            }
            
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
            self.socialEmail = nil
            
        }
       
    }
    
    
    // GOOGLE Delegate methods
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if (error == nil) {
            
            self.validateAndRegisterLogin(user.profile.email, pass: nil, name:nil, loggedInMode: kLoggedinThroughGoogle)
            self.socialEmail = user.profile.email
            
        }
        else {
            
            self.stopAnimating()
            Common.sharedCommon.config!["loggedInMode"] = kLoggedInYetToLogin
            Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Google Authentication Error",startTimer:true)
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
        
    }

}
