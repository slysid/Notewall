//
//  CustomButton.swift
//  Notewall
//
//  Created by Bharath on 24/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class CustomButton:UIButton {
    
    var indexPath:NSIndexPath?
    
    init(frame: CGRect, buttonTitle:String, normalColor:UIColor?, highlightColor:UIColor?) {
        
        super.init(frame: frame)
        
        self.setTitle(buttonTitle, forState: UIControlState.Normal)
        self.setTitleColor(normalColor, forState: UIControlState.Normal)
        self.setTitleColor(highlightColor, forState: UIControlState.Highlighted)
        self.backgroundColor = UIColor.whiteColor()
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
