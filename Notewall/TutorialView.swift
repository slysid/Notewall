//
//  TutorialView.swift
//  Pinwall
//
//  Created by Bharath on 25/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit


class TutorialView:UIView,CloseViewProtocolDelegate {
    
    var closeButton:CloseView?
    var pageControl:UIPageControl?
    var tutText:UILabel?
    var currentPageIndex = 0
    var texts = ["TAP ONCE TO CHANGE BOARD","TAP TWICE TO CREATE NEW NOTE","SWIPE DOWN TO DELETE A NOTE"]
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        self.backgroundColor = UIColor.whiteColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        self.userInteractionEnabled = true
        self.opaque = false
        self.alpha = 0.8
        //self.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * 2,UIScreen.mainScreen().bounds.size.height)
        
        let dim = Common.sharedCommon.calculateDimensionForDevice(35)
        self.closeButton = CloseView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - dim , 0, dim, dim))
        self.closeButton?.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        self.closeButton?.closeViewDelegate = self
        self.addSubview(self.closeButton!)
        
        self.tutText = UILabel(frame:CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,Common.sharedCommon.calculateDimensionForDevice(250)))
        self.tutText!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5,UIScreen.mainScreen().bounds.size.height * 0.5)
        self.tutText!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin).union(.FlexibleRightMargin).union(.FlexibleLeftMargin).union(.FlexibleWidth).union(.FlexibleHeight)
        self.tutText!.userInteractionEnabled = true
        self.tutText!.font = UIFont(name: "Roboto", size: 50.0)
        self.tutText!.textColor = UIColor.blackColor()
        self.tutText!.text = texts[currentPageIndex]
        self.tutText!.numberOfLines = 0
        self.tutText!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.tutText!.textAlignment = NSTextAlignment.Center
        self.addSubview(self.tutText!)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "swiped:")
        leftSwipe.direction = .Left
        self.tutText!.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "swiped:")
        rightSwipe.direction = .Right
        self.tutText!.addGestureRecognizer(rightSwipe)
        
        
        let width = Common.sharedCommon.calculateDimensionForDevice(300)
        let height = Common.sharedCommon.calculateDimensionForDevice(50)
        self.pageControl = UIPageControl(frame: CGRectMake(0,0,width,height))
        self.pageControl!.numberOfPages = self.texts.count
        self.pageControl!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.95)
        self.pageControl!.pageIndicatorTintColor = UIColor.redColor()
        self.pageControl!.currentPageIndicatorTintColor = UIColor.blueColor()
        self.pageControl!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin)
        self.addSubview(self.pageControl!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func swiped(sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == UISwipeGestureRecognizerDirection.Right) {
            
            currentPageIndex = currentPageIndex - 1
            
            if (currentPageIndex < 0) {
                
                currentPageIndex = texts.count - 1
            }
            
        }
        else {
            
            currentPageIndex = currentPageIndex + 1
            
            if (currentPageIndex >= texts.count) {
                
                currentPageIndex = 0
            }
        }
        
        self.pageControl!.currentPage = currentPageIndex
        self.pageControl!.updateCurrentPageDisplay()
        self.tutText!.text = texts[currentPageIndex]
    }
    
    // DELEGATE METHODS
    
    func handleCloseViewTap() {
        
        self.removeFromSuperview()
    }
    
    
}
