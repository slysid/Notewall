//
//  TextNote.swift
//  Pinwall
//
//  Created by Bharath on 21/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class TextNote:UIImageView {
    
    var noteImage:UIImage?
    var filledtextView:UITextView?
    
    
    init(frame:CGRect, withImageName:String?, withText:NSString?,preferredFont:String?, preferredFontSize:CGFloat?,preferredFontColor:UIColor?, addExpiry:Bool, expiryDate:String?) {
        
        super.init(frame:frame)
        
        var font:String?
        var fontSize:CGFloat = kStickyNoteFontSize
        var fontColor:UIColor = kDefaultFontColor
        var msg:NSMutableAttributedString?
        
        if (preferredFont == nil) {
            
            font = kDefaultFont
        }
        else {
            
            font = preferredFont
        }
        
        if (preferredFontSize != nil) {
            
            fontSize = preferredFontSize!
        }
        
        if (preferredFontColor != nil) {
            
            fontColor = preferredFontColor!
        }
        
        let textFont: UIFont = UIFont(name: font!, size: fontSize)!
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: fontColor,
        ]
        
        if (addExpiry == false) {
            
            msg = NSMutableAttributedString(string: withText as! String, attributes: textFontAttributes)
        }
        else {
            
            let dateText = expiryDate! + " \n"
            let dateTextFont: UIFont = UIFont(name:"Arial",size:8.0)!
            let dateTextFontAttributes = [
                NSFontAttributeName: dateTextFont,
                NSForegroundColorAttributeName: fontColor,
            ]
            
            msg = NSMutableAttributedString(string: dateText, attributes: dateTextFontAttributes)
            let msg1 = NSMutableAttributedString(string: withText as! String, attributes: textFontAttributes)
            msg!.appendAttributedString(msg1)
        }
        
        self.backgroundColor = UIColor.clearColor()
        
        noteImage = UIImage(named: withImageName!)
        self.image = self.noteImage!
        
        let textRect = CGRectInset(self.bounds,self.bounds.size.width * 0.10,self.bounds.size.width * 0.10)
        self.filledtextView = UITextView(frame: textRect)
        self.filledtextView!.font = UIFont(name: preferredFont!, size: preferredFontSize!)
        self.filledtextView!.textColor = preferredFontColor!
        self.filledtextView!.backgroundColor = UIColor.clearColor()
        self.filledtextView!.editable = false
        self.filledtextView!.attributedText = msg!
        self.filledtextView!.clipsToBounds = true
        self.addSubview(self.filledtextView!)
        
       
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}