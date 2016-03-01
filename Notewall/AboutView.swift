//
//  AboutView.swift
//  Pinwall
//
//  Created by Bharath on 27/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class AboutView:UIView {
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        self.backgroundColor = kOptionsBgColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
