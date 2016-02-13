//
//  MessageView.swift
//  Pinwall
//
//  Created by Bharath on 13/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class MessageView:UILabel {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.font = UIFont(name: "chalkduster", size: 33.0)
        self.textAlignment = NSTextAlignment.Center
        self.textColor = UIColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
