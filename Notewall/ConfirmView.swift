//
//  ConfirmView.swift
//  Pinwall
//
//  Created by Bharath on 24/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol ConfirmProtocolDelegate {
    
    func okTapped(sender:ConfirmView, requester:AnyObject?)
    func cancelTapped(sender:ConfirmView, requester:AnyObject?)
}

class ConfirmView:UIView {
    
    var confirmDelegate:ConfirmProtocolDelegate?
    var requester:AnyObject?
    
    init(frame: CGRect, requester:AnyObject?) {
        
        super.init(frame:frame)
        self.userInteractionEnabled = true
        self.requester = requester
        
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(.FlexibleTopMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        
        let textLabel = UILabel(frame: CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height * 0.70))
        textLabel.font = UIFont(name: "chalkduster", size: 40.0)
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.textColor = UIColor.whiteColor()
        textLabel.text = "Delete Note"
        self.addSubview(textLabel)
        
        let okBoundry = UIView(frame: CGRectMake(0,textLabel.bounds.size.height,self.bounds.size.width * 0.5,self.bounds.size.height * 0.30))
        okBoundry.userInteractionEnabled = true
        self.addSubview(okBoundry)
        let okTap = UITapGestureRecognizer(target: self, action: #selector(ConfirmView.okTapped))
        okBoundry.addGestureRecognizer(okTap)
        
        let okImage = UIImageView(frame: CGRectMake(0,0,self.bounds.size.height * 0.30,self.bounds.size.height * 0.30))
        okImage.center = CGPointMake(self.bounds.size.width * 0.25, textLabel.frame.size.height + okImage.frame.size.height * 0.5)
        okImage.image = UIImage(named: "ok.png")
        self.addSubview(okImage)
        
        let cancelBoundry = UIView(frame: CGRectMake(okBoundry.bounds.size.width,okBoundry.frame.origin.y,self.bounds.size.width * 0.5,self.bounds.size.height * 0.30))
        cancelBoundry.userInteractionEnabled = true
        self.addSubview(cancelBoundry)
        let cancelTap = UITapGestureRecognizer(target: self, action: #selector(ConfirmView.cancelTapped))
        cancelBoundry.addGestureRecognizer(cancelTap)
        
        let cancelImage = UIImageView(frame: CGRectMake(0,0,okImage.frame.size.width,okImage.frame.size.height))
        cancelImage.center = CGPointMake(self.bounds.size.width * 0.75, okImage.center.y)
        cancelImage.image = UIImage(named: "cancel.png")
        
        self.addSubview(cancelImage)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeSelf() {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.alpha = 0.0
            
            }) { (Bool) -> Void in
                
                self.removeFromSuperview()
        }
    }
    
    func cancelTapped() {
        
        self.removeSelf()
        
        if (self.confirmDelegate != nil) {
            
            self.confirmDelegate?.cancelTapped(self,requester: self.requester)
        }
    }
    
    func okTapped() {
        
        self.removeSelf()
        
        if (self.confirmDelegate != nil) {
            
            self.confirmDelegate?.okTapped(self, requester: self.requester)
        }
    }
}
