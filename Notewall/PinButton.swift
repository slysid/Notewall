//
//  RoundButton.swift
//  Pin!t
//
//  Created by Bharath on 21/03/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol PinButtonProtocolDelegate {
    
    func postAndDeductPinType(pintype:String)
}

class PinButton:UIButton {
    
    var pinType:String?
    var pinButtonDelegate:PinButtonProtocolDelegate?
    
    init(frame: CGRect,type:String,PinCount:String) {
        
        super.init(frame:frame)
        
        var pinBG:String?
        pinType = type
        
        if ((type.lowercaseString.rangeOfString("gold")) != nil) {
            
            pinBG = "goldpin.jpg"
        }
        else if((type.lowercaseString.rangeOfString("silver")) != nil) {
            
            pinBG = "silverpin.jpg"
        }
        else if((type.lowercaseString.rangeOfString("bronze")) != nil) {
            
            pinBG = "bronzepin.jpg"
        }
        else{
            
            pinBG = "bronzepin.jpg"
        }
        
        let goldColor = UIColor(patternImage: UIImage(named: pinBG!)!)
        self.backgroundColor = goldColor
        self.layer.cornerRadius = self.frame.size.width * 0.5
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        self.titleLabel!.font = UIFont(name: "Roboto", size: Common.sharedCommon.calculateDimensionForDevice(14))
        
        self.addTarget(self, action: #selector(PinButton.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.setTitle(PinCount, forState: UIControlState.Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTapped(sender:PinButton) {
        
        if (Int(sender.titleLabel!.text!)! <= 0 ){
            
        }
        else {
            
            if (pinButtonDelegate != nil) {
                
                self.pinButtonDelegate!.postAndDeductPinType(sender.pinType!)
            }
        }
    }
}
