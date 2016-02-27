//
//  OptionsItem.swift
//  Pinwall
//
//  Created by Bharath on 25/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol OptionsItemProtocolDelegate {
    
    func handleTapped(item:OptionsItem)
}

class OptionsItem:UIView {
    
    var optionsViewProtocolDelegate:OptionsItemProtocolDelegate?
    var titleLabel:UILabel?
    
    init(frame: CGRect, withText:String?,withImageName:String?) {
        
        super.init(frame:frame)
        self.userInteractionEnabled = true
        self.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin.union(.FlexibleWidth).union(.FlexibleLeftMargin)
        
        let imgDim = Common.sharedCommon.calculateDimensionForDevice(25)
        let imageView = UIImageView(frame: CGRectMake(0,0,imgDim,imgDim))
        imageView.center = CGPointMake(imgDim * 0.5,self.frame.size.height * 0.5)
        self.addSubview(imageView)
        
        if (withImageName != nil) {
            
                imageView.image = UIImage(named:withImageName!)
        }
        
        titleLabel = UILabel(frame: CGRectMake(imageView.frame.size.width,0,self.bounds.size.width - imageView.frame.size.width,self.bounds.size.height))
        titleLabel!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        titleLabel!.userInteractionEnabled = true
        titleLabel!.font = UIFont(name: "Roboto", size: 13.0)
        titleLabel!.textAlignment = NSTextAlignment.Center
        titleLabel!.textColor = UIColor.whiteColor()
        //titleLabel.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleWidth)
        self.addSubview(titleLabel!)
        
        let tap = UITapGestureRecognizer(target: self, action: "tapped:")
        titleLabel!.addGestureRecognizer(tap)
        
        if (withText != nil) {
            
            titleLabel!.text = withText
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapped(sender:UITapGestureRecognizer) {
        
        if (optionsViewProtocolDelegate != nil) {
            
            self.optionsViewProtocolDelegate!.handleTapped(self)
        }
    }
}
