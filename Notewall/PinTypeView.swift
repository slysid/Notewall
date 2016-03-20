//
//  PinCounterView.swift
//  Pin!t
//
//  Created by Bharath on 19/03/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol PinTypeBuyProtocolDelegate {
    
    func postAndDeductPinType(pintype:String)
}

class PinTypeView:UIView {
    
    var pinText:UILabel?
    var pinCount:UILabel?
    var pinTypeDelegate:PinTypeBuyProtocolDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        self.pinText = UILabel(frame:CGRectMake(0,0,self.frame.size.width * 0.75,self.frame.size.height))
        self.pinText!.textAlignment = NSTextAlignment.Left
        self.pinText!.textColor = UIColor.whiteColor()
        self.pinText!.font = UIFont(name: "Roboto", size: 14.0)
        self.pinText!.userInteractionEnabled = true
        self.addSubview(pinText!)
        
        let pinTextTap = UITapGestureRecognizer(target: self, action: "pinTextTapped:")
        self.pinText!.addGestureRecognizer(pinTextTap)
        
        self.pinCount = UILabel(frame:CGRectMake(self.pinText!.frame.size.width,0,self.frame.size.width * 0.25,self.frame.size.height))
        self.pinCount!.textAlignment = NSTextAlignment.Left
        self.pinCount!.textColor = UIColor.whiteColor()
        self.pinCount!.font = UIFont(name: "Roboto", size: 14.0)
        self.pinCount!.backgroundColor = UIColor.redColor()
        self.addSubview(pinCount!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func pinTextTapped(sender:UITapGestureRecognizer) {
        
        let view = sender.view as! UILabel
        let type = view.text
        
        if (pinTypeDelegate != nil) {
            
            self.pinTypeDelegate!.postAndDeductPinType(type!)
        }
    }
    
}
