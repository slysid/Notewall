//
//  OptionsView.swift
//  Pinwall
//
//  Created by Bharath on 25/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol OptionsViewProtocolDelegate {
    
    func handleTappedOptionItem(item:OptionsItem)
}

class OptionsView:UIView,OptionsItemProtocolDelegate {
    
    var delegate:OptionsViewProtocolDelegate?
    
    init(frame: CGRect, options:Dictionary<Int,Dictionary<String,String>>) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleRightMargin)
        self.userInteractionEnabled = true
        
        var xPos:CGFloat = 0.0
        let yPos:CGFloat = 0.0
        let width:CGFloat = self.frame.size.width / CGFloat(options.count)
        let height = self.frame.size.height
        let keys = options.keys.sort()
        
        for key in keys {
            
            let img = options[key]!["icon"]! as String
            let title = options[key]!["title"]! as String
            let optionItem = OptionsItem(frame: CGRectMake(xPos,yPos,width,height), withText: title, withImageName:img)
            optionItem.optionsViewProtocolDelegate = self
            optionItem.tag = key
            self.addSubview(optionItem)
            
            xPos = xPos + width
        }
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   func handleTapped(item: OptionsItem) {
        
        if (delegate != nil) {
            
            self.delegate!.handleTappedOptionItem(item)
            
        }
        
    }
}
