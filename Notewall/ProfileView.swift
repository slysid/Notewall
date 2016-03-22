//
//  ProfileView.swift
//  Pinwall
//
//  Created by Bharath on 27/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileViewProtocolDelegate {
    
    func updateScreenName(name:String,completion:(Bool,String) -> Void)
    func updatePassword(oldpassword:String,newpassword:String,completion:(Bool,String) -> Void)
}

class ProfileView:UIView,UITextFieldDelegate {
    
    var nameView:UITextField?
    var changeScreenNameImageView:UIImageView?
    var emailLabel:UILabel?
    var passwordLabel:UILabel?
    var changePasswordImageView:UIImageView?
    var oldPassword:UITextField?
    var newPassword:UITextField?
    var confirmPassword:UITextField?
    var passwordFieldEditStatus:Bool = false
    var nameFieldEditStatus:Bool = false
    let animateDuration:NSTimeInterval = 0.2
    let distanceBetween:CGFloat = 15.0
    var defaultPosition:CGPoint?
    var profileViewDelegate:ProfileViewProtocolDelegate?
    var activity:UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)

        self.backgroundColor = kOptionsBgColor
        //self.backgroundColor = UIColor.blackColor()
        let xOffset:CGFloat = 35.0
        let textFieldHeight:CGFloat = 45.0
        let textFieldWidth = UIScreen.mainScreen().bounds.size.width - (xOffset * 2)
        
        defaultPosition = self.center
        
        
        nameView = UITextField(frame: CGRectMake(xOffset,70,textFieldWidth,textFieldHeight))
        nameView!.backgroundColor = UIColor.clearColor()
        //nameView!.editable = false
        nameView!.delegate = self
        nameView!.text = Common.sharedCommon.config!["screenname"] as? String
        nameView!.font = UIFont(name: "Roboto", size: 20.0)
        nameView!.textAlignment = NSTextAlignment.Left
        nameView!.alpha = 0.0
        nameView!.textColor = UIColor.blackColor()
        nameView!.returnKeyType = UIReturnKeyType.Send
        nameView!.autocapitalizationType = UITextAutocapitalizationType.None
        nameView!.autocorrectionType = UITextAutocorrectionType.No
        nameView!.spellCheckingType = UITextSpellCheckingType.No
        self.addSubview(nameView!)
        
        changeScreenNameImageView = UIImageView(frame: CGRectMake(nameView!.frame.origin.x + nameView!.frame.size.width,nameView!.frame.origin.y,nameView!.frame.size.height * 0.5,nameView!.frame.size.height * 0.5))
        changeScreenNameImageView!.image = UIImage(named:"edit.png")
        changeScreenNameImageView!.center = CGPointMake(changeScreenNameImageView!.center.x,nameView!.center.y)
        changeScreenNameImageView!.alpha = 0.0
        changeScreenNameImageView!.userInteractionEnabled = true
        self.addSubview(changeScreenNameImageView!)
        let editTap = UITapGestureRecognizer(target:self, action: #selector(ProfileView.editTapped))
        changeScreenNameImageView!.addGestureRecognizer(editTap)
        
        emailLabel = UILabel(frame: CGRectMake(nameView!.frame.origin.x,nameView!.frame.origin.y + nameView!.frame.size.height + distanceBetween,nameView!.frame.size.width ,nameView!.frame.size.height))
        emailLabel!.text = Common.sharedCommon.config!["email"] as? String
        emailLabel!.font = nameView!.font
        emailLabel!.textAlignment = nameView!.textAlignment
        emailLabel!.alpha = nameView!.alpha
        emailLabel!.textColor = nameView!.textColor
        self.addSubview(emailLabel!)
        
        
        passwordLabel = UILabel(frame: CGRectMake(emailLabel!.frame.origin.x,emailLabel!.frame.origin.y + emailLabel!.frame.size.height + (1.5 * distanceBetween),emailLabel!.frame.size.width ,emailLabel!.frame.size.height))
        passwordLabel!.text = "Password"
        passwordLabel!.font = nameView!.font
        passwordLabel!.textAlignment = nameView!.textAlignment
        passwordLabel!.alpha = nameView!.alpha
        passwordLabel!.textColor = nameView!.textColor
        self.addSubview(passwordLabel!)
        
        
        
        changePasswordImageView = UIImageView(frame: CGRectMake(passwordLabel!.frame.origin.x + passwordLabel!.frame.size.width,passwordLabel!.frame.origin.y,passwordLabel!.frame.size.height * 0.5,passwordLabel!.frame.size.height * 0.5))
        changePasswordImageView!.image = UIImage(named:"edit.png")
        changePasswordImageView!.center = CGPointMake(changeScreenNameImageView!.center.x,passwordLabel!.center.y)
        changePasswordImageView!.alpha = 0.0
        changePasswordImageView!.userInteractionEnabled = true
        self.addSubview(changePasswordImageView!)
        let passTap = UITapGestureRecognizer(target:self, action: #selector(ProfileView.passTapped))
        changePasswordImageView!.addGestureRecognizer(passTap)
        
        let dim = Common.sharedCommon.calculateDimensionForDevice(50)
        activity = UIActivityIndicatorView(frame: CGRectMake(0,0,dim,dim))
        activity!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5,200)
        self.addSubview(activity!)
        activity!.tintColor = UIColor.redColor()
        
        //oldPassword = UITextField(frame: CGRectMake(xOffset,10,textFieldWidth,textFieldHeight))
        oldPassword =  UITextField(frame: CGRectMake(xOffset,passwordLabel!.frame.origin.y + passwordLabel!.frame.size.height + distanceBetween,textFieldWidth,textFieldHeight))
        oldPassword!.backgroundColor = UIColor.clearColor()
        oldPassword!.delegate = self
        oldPassword!.secureTextEntry = true
        oldPassword!.attributedPlaceholder = self.returnAttributedString("Old Password")
        oldPassword!.font = UIFont(name: "Roboto", size: 15.0)
        oldPassword!.textAlignment = nameView!.textAlignment
        oldPassword!.alpha = nameView!.alpha
        oldPassword!.textColor = nameView!.textColor
        oldPassword!.returnKeyType = UIReturnKeyType.Send
        self.addSubview(oldPassword!)
        
        newPassword =  UITextField(frame: CGRectMake(xOffset,oldPassword!.frame.origin.y + oldPassword!.frame.size.height + distanceBetween,textFieldWidth,textFieldHeight))
        //newPassword =  UITextField(frame: CGRectMake(xOffset,passwordLabel!.frame.origin.y + passwordLabel!.frame.size.height + distanceBetween,textFieldWidth,textFieldHeight))
        newPassword!.backgroundColor = UIColor.clearColor()
        newPassword!.delegate = self
        newPassword!.secureTextEntry = true
        newPassword!.attributedPlaceholder = self.returnAttributedString("New Password")
        newPassword!.font = oldPassword!.font
        newPassword!.textAlignment = nameView!.textAlignment
        newPassword!.alpha = nameView!.alpha
        newPassword!.textColor = nameView!.textColor
        newPassword!.returnKeyType = UIReturnKeyType.Send
        self.addSubview(newPassword!)
        
        
        confirmPassword =  UITextField(frame: CGRectMake(xOffset,newPassword!.frame.origin.y + newPassword!.frame.size.height + distanceBetween,textFieldWidth,textFieldHeight))
        //confirmPassword =  UITextField(frame: CGRectMake(xOffset,passwordLabel!.frame.origin.y + passwordLabel!.frame.size.height + distanceBetween,textFieldWidth,textFieldHeight))
        confirmPassword!.backgroundColor = UIColor.clearColor()
        confirmPassword!.delegate = self
        confirmPassword!.secureTextEntry = true
        confirmPassword!.attributedPlaceholder = self.returnAttributedString("Confirm Password")
        confirmPassword!.font = oldPassword!.font
        confirmPassword!.textAlignment = nameView!.textAlignment
        confirmPassword!.alpha = nameView!.alpha
        confirmPassword!.textColor = nameView!.textColor
        confirmPassword!.returnKeyType = UIReturnKeyType.Send
        self.addSubview(confirmPassword!)
        
        UIView.animateWithDuration(animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
            
            self.nameView!.alpha = 1.0
            self.changeScreenNameImageView!.alpha = 1.0
            
            }) { (Bool) -> Void in
                
                UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                        self.emailLabel!.alpha = 1.0

                    }, completion: { (Bool) -> Void in
                        
                        
                        UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                            
                            
                            if ( Common.sharedCommon.config!["loggedInMode"] as! String == kLoggedinThroughMail) {
                                
                                self.passwordLabel!.alpha = 1.0
                                self.changePasswordImageView!.alpha = 1.0
                            }
                            
                            }, completion: { (Bool) -> Void in
                                
                                
                        })
                        
                        
                })
                
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // UITEXTFIELD DELEGATE METHODS
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField == self.oldPassword || textField == self.newPassword || textField == self.confirmPassword) {
            
            return passwordFieldEditStatus
        }
        
        if (textField == self.nameView) {
            
            return nameFieldEditStatus
        }
        
        
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == self.nameView!) {
            
            self.nameView!.resignFirstResponder()
            if (self.validateEntry() == true) {
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.activity!.startAnimating()
                }
                
                if (profileViewDelegate != nil ) {
                    
                    self.profileViewDelegate!.updateScreenName(self.nameView!.text!, completion: { (result,message) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            
                            self.activity!.stopAnimating()
                            self.nameView!.resignFirstResponder()
                        }
                        
                        if (result == true) {
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                Common.sharedCommon.config!["screenname"] = self.nameView!.text
                                //self.nameView!.editable = false
                                self.nameFieldEditStatus = false
                                self.nameView!.resignFirstResponder()
                                self.changeScreenNameImageView!.image = UIImage(named:"edit.png")
                                FileHandler.sharedHandler.writeToFileWithData(Common.sharedCommon.config!, filename: "Config")
                            })
                        }
                        
                    })
                }
                
            }
            
            return true
        }
        else if (textField == self.oldPassword || textField == self.newPassword || textField == self.confirmPassword) {
            
            self.oldPassword!.resignFirstResponder()
            self.newPassword!.resignFirstResponder()
            self.confirmPassword!.resignFirstResponder()
            
            if (self.validatePassword() == true) {
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.activity!.startAnimating()
                }
                
                if (self.profileViewDelegate != nil) {
                    
                    self.profileViewDelegate!.updatePassword(self.oldPassword!.text!, newpassword: self.newPassword!.text!, completion: { (result, message) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            
                            self.activity!.stopAnimating()
                        }
                        
                        if (result == false) {
                            
                            
                            Common.sharedCommon.showMessageViewWithMessage(self, message: message, startTimer: true)
                        }
                        else {
                            
                            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                
                                self.passwordFieldEditStatus = false
                                self.changePasswordImageView!.image = UIImage(named:"edit.png")
                            }
                            
                        }
                        
                    })
                    
                }
                
                return true
            }
            else {
                
                self.oldPassword!.becomeFirstResponder()
                return true
            }
        }
        
        return false
    }
    
    // CUSTOM METHODS
    
    func returnAttributedString(str:String) -> NSAttributedString {
        
        return NSAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func editTapped() {
        
        if (self.nameView!.isFirstResponder() == false) {
            
            self.nameFieldEditStatus = true
            //self.nameView!.editable = true
            self.nameView!.becomeFirstResponder()
            changeScreenNameImageView!.image = UIImage(named:"cancel.png")
        }
        else {
            
            self.nameFieldEditStatus = false
            //self.nameView!.editable = true
            self.nameView!.resignFirstResponder()
            changeScreenNameImageView!.image = UIImage(named:"edit.png")
        }
        
    }
    
    func passTapped() {
        
        if (passwordFieldEditStatus == false ) {
            
            if (self.oldPassword!.alpha == 0.0) {
                
                self.defaultPosition = self.center
                self.center = CGPointMake(self.center.x,self.center.y - (self.passwordLabel!.frame.origin.y + self.passwordLabel!.frame.size.height - (6 * distanceBetween)))
            }
            
            changePasswordImageView!.image = UIImage(named:"cancel.png")
            passwordFieldEditStatus = true
            
            UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                
                self.oldPassword!.alpha = 1.0
                
                }) { (Bool) -> Void in
                    
                    UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                        
                        self.newPassword!.alpha = 1.0
                        
                        }, completion: { (Bool) -> Void in
                            
                            
                           UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                                
                                self.confirmPassword!.alpha = 1.0
                               
                                
                                }, completion: { (Bool) -> Void in
                                    
                                    
                                    self.oldPassword!.becomeFirstResponder()
                            })
                            
                            
                    })
                    
            }
        }
        else {
            
           self.center = self.defaultPosition!
           
            if (self.oldPassword!.isFirstResponder()) {
                
                self.oldPassword!.resignFirstResponder()
            }
            
            if (self.newPassword!.isFirstResponder()) {
                
                self.newPassword!.resignFirstResponder()
            }
            
            if (self.confirmPassword!.isFirstResponder()) {
                
                self.confirmPassword!.resignFirstResponder()
            }
            
            self.oldPassword!.alpha = 0.0
            self.newPassword!.alpha = 0.0
            self.confirmPassword!.alpha = 0.0
            changePasswordImageView!.image = UIImage(named:"edit.png")
            passwordFieldEditStatus = false
            
          /*  if (self.validateEntry() == true) {
                
                changePasswordImageView!.image = UIImage(named:"edit.png")
                passwordFieldEditStatus = false
                
                if (self.oldPassword!.isFirstResponder()) {
                    
                    self.oldPassword!.resignFirstResponder()
                }
                
                if (self.newPassword!.isFirstResponder()) {
                    
                    self.newPassword!.resignFirstResponder()
                }
                
                if (self.confirmPassword!.isFirstResponder()) {
                    
                    self.confirmPassword!.resignFirstResponder()
                }
                
                UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    self.confirmPassword!.alpha = 0.0
                    
                    }) { (Bool) -> Void in
                        
                        UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                            
                            self.newPassword!.alpha = 0.0
                            
                            }, completion: { (Bool) -> Void in
                                
                                
                                UIView.animateWithDuration(self.animateDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                                    
                                    self.oldPassword!.alpha = 0.0
                                    
                                    
                                    }, completion: { (Bool) -> Void in
                                        
                                        
                                })
                                
                                
                        })
                        
                }
                
            } */
            
        }
        
    }
    
    func validateEntry() -> Bool {
        
        if (self.nameView!.text!.characters.count < 3) {
            
            return false
            
        }
        
        return true
    }
    
    func validatePassword() -> Bool {
        
        let oldPassText = self.oldPassword!.text
        let newPassText = self.newPassword!.text
        let confirmPassText = self.confirmPassword!.text
        
        if (oldPassText == "" || oldPassText == nil) {
            
            Common.sharedCommon.showMessageViewWithMessage(self, message: "Old Password needed", startTimer: true)
            return false
        }
        
        if (newPassText == "" || newPassText == nil || confirmPassText == "" || confirmPassText == nil) {
            
            Common.sharedCommon.showMessageViewWithMessage(self, message: "New Password needed", startTimer: true)
            return false
        }
        
        if (newPassText != confirmPassText) {
            
            Common.sharedCommon.showMessageViewWithMessage(self, message: "Passwords Doesn't Match", startTimer: true)
            return false
        }
        
        return true
    }

}