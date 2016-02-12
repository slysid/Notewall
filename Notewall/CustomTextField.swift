//
//  CustomTextField.swift
//  Pinwall
//
//  Created by Bharath on 09/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class CustomTextField:UITextField {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.textColor = UIColor.blackColor()
        self.returnKeyType = UIReturnKeyType.Send
        self.font = UIFont(name: "chalkduster", size: 25.0)
        self.keyboardType = UIKeyboardType.EmailAddress
        self.autocapitalizationType = UITextAutocapitalizationType.None
        self.autocorrectionType = UITextAutocorrectionType.No
        self.spellCheckingType = UITextSpellCheckingType.No
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
