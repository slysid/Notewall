//
//  CloseView.swift
//  Pinwall
//
//  Created by Bharath on 09/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol CloseViewProtocolDelegate {
    
    func handleCloseViewTap()
}

class CloseView:UIImageView {
    
    var closeViewDelegate:CloseViewProtocolDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.image = UIImage(named: "close.png")
        self.userInteractionEnabled = true
        let closeImgTap = UITapGestureRecognizer(target: self, action: "buttonTapped:")
        self.addGestureRecognizer(closeImgTap)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func buttonTapped(sender:UITapGestureRecognizer) {
        
        if (closeViewDelegate != nil) {
            
            closeViewDelegate!.handleCloseViewTap()
        }
        
    }
    
    
    
}
