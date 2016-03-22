//
//  ComposeNote.swift
//  Pinwall
//
//  Created by Bharath on 07/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol ComposeNoteDelegate {
    
    func composeDismissKeyboard()
    func composeNoteSwipped()
}

class ComposeNote:UIImageView {
    
    var composeTextView:UITextView?
    var composeNoteDelegate:ComposeNoteDelegate?
    
    init(frame: CGRect, withImage:String, withFontSize:CGFloat) {
        
        super.init(frame: frame)
        
        self.image = UIImage(named: withImage)
        self.userInteractionEnabled = true
        
        let textFieldFrame = CGRectInset(self.bounds, Common.sharedCommon.calculateDimensionForDevice(40), Common.sharedCommon.calculateDimensionForDevice(40))
        
        composeTextView = UITextView(frame: textFieldFrame)
        composeTextView!.backgroundColor = UIColor.clearColor()
        composeTextView!.textColor = Common.sharedCommon.formColorWithRGB(kFontColor[0])
        composeTextView!.font = UIFont(name: "Chalkduster", size: withFontSize)
        composeTextView!.becomeFirstResponder()
        composeTextView!.userInteractionEnabled = false
        self.addSubview(composeTextView!)
        
        let noteTap = UITapGestureRecognizer(target: self, action: #selector(ComposeNote.dimissKeyboard))
        self.addGestureRecognizer(noteTap)
        
        let noteSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ComposeNote.noteSwiped))
        noteSwipe.direction = .Down
        self.addGestureRecognizer(noteSwipe)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Gesture Delegate Methods
    
    
    func dimissKeyboard() {
        
        if (self.composeNoteDelegate != nil) {
            
            self.composeNoteDelegate!.composeDismissKeyboard()
        }
        
    }
    
    func noteSwiped() {
        
        if (self.composeNoteDelegate != nil) {
            
            self.composeNoteDelegate!.composeNoteSwipped()
        }
    }
}
