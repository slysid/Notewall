//
//  SettingsController.swift
//  Pin!t
//
//  Created by Bharath on 08/04/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsControllerProtocolDelegate {
    
    func handleSettingsSelector(sel:String)
}


class SettingsController:UIViewController {
    
    var settingsDelegate:SettingsControllerProtocolDelegate?
    
    override func loadView() {
        
        self.view = UIView(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,Common.sharedCommon.calculateDimensionForDevice(40)))
    }

    override func viewDidLoad() {
        
        self.view.backgroundColor = kOptionsBgColor
        
        let numberOfOptions = kSettingsOptions.count
        var optionsWidth = self.view.frame.size.width / CGFloat(numberOfOptions)
        let contentSizeWidth = optionsWidth * CGFloat(numberOfOptions - 1)
        if numberOfOptions > 6 {
            
            optionsWidth = self.view.frame.size.width / 6.0
        }
        
        let settingsScrollView = UIScrollView(frame: CGRectMake(0,0,self.view.frame.size.width - optionsWidth,self.view.frame.size.height))
        settingsScrollView.contentSize = CGSizeMake(contentSizeWidth,settingsScrollView.frame.size.height)
        settingsScrollView.backgroundColor = UIColor.clearColor()
        settingsScrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(settingsScrollView)
        
        var xPos:CGFloat = 0
        
        for index in 0 ... numberOfOptions - 2 {
            
            let holderView = UIView(frame:CGRectMake(xPos,0,optionsWidth,self.view.frame.size.height))
            let imgView = UIImageView(frame:CGRectMake(0,0,holderView.frame.size.height,holderView.frame.size.height))
            imgView.tag = index
            imgView.center = CGPointMake(holderView.frame.size.width * 0.5,holderView.frame.size.height * 0.5)
            imgView.userInteractionEnabled = true
            let imgTap = UITapGestureRecognizer(target: self, action:#selector(SettingsController.optionTapped(_:)))
            imgView.addGestureRecognizer(imgTap)
            let imageName = kSettingsOptions[index]["icon"]! as String
            imgView.image = UIImage(named:imageName)
            holderView.addSubview(imgView)
            settingsScrollView.addSubview(holderView)
            
            xPos = xPos + optionsWidth
        }
        
        let logoutView  = UIView(frame: CGRectMake(settingsScrollView.frame.size.width,settingsScrollView.frame.origin.y,optionsWidth,self.view.frame.size.height))
        let logoutImage = UIImageView(frame: CGRectMake(0,0,logoutView.frame.size.height,logoutView.frame.size.height))
        logoutImage.tag = kSettingsOptions.count - 1
        logoutImage.center = CGPointMake(logoutView.frame.size.width * 0.5,logoutView.frame.size.height * 0.5)
        logoutImage.userInteractionEnabled = true
        let imgTap = UITapGestureRecognizer(target: self, action:#selector(SettingsController.optionTapped(_:)))
        logoutImage.addGestureRecognizer(imgTap)
        let imageName = kSettingsOptions[kSettingsOptions.count - 1]["icon"]! as String
        logoutImage.image = UIImage(named: imageName)
        logoutView.addSubview(logoutImage)
        self.view.addSubview(logoutView)
        
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    // PRIVATE METHODS
    
    func optionTapped(sender:UITapGestureRecognizer) {
        
        let view = sender.view
        let selector = kSettingsOptions[view!.tag]["selector"]! as String
        
        if (self.settingsDelegate != nil) {
            
            self.settingsDelegate!.handleSettingsSelector(selector)
        }
    }
}
