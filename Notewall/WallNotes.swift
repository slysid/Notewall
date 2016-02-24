//
//  WallNotes.swift
//  Notewall
//
//  Created by Bharath on 22/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol WallNoteDelegate {
    
    func blowupWallNote(note:WallNote)
}

class WallNote:UIImageView {
    
    var stickyNoteID:String?
    var stickyNoteType:String?
    var stickyNoteText:NSString?
    var stickyNoteFont:String?
    var stickyNoteFontSize:CGFloat?
    var stickyNoteFontColor:UIColor?
    var stickyNoteCreationDate:String?
    var stickyNoteDeletionDate:String?
    var noteTag:Int = 0
    var isAlreadyBlownUp:Bool = false
    var wallnoteDelegate:WallNoteDelegate?
    var favedOwners:Array<String>?
    var polaroid:UIImageView?
    var isNote = true
    var imageFileName:String?
    var imageThumbData:NSData?
    
    init(frame: CGRect, noteType:String?, noteText:String, noteFont:String?, noteFontSize:CGFloat?,noteFontColor:UIColor?, isNote:Bool, imageFileName:String?) {
        
        super.init(frame: frame)
        
        self.isNote = isNote
        
        if (isNote == true) {
            
            if (noteType != nil) {
                
                stickyNoteType = noteType
            }
            else {
                
                stickyNoteType = kDefaultNoteType
            }
            
            stickyNoteText = noteText
            
            if (noteFont != nil) {
                
                stickyNoteFont = noteFont
            }
            else {
                
                stickyNoteFont = kDefaultFont
            }
            
            if (noteFontSize != nil) {
                
                stickyNoteFontSize = noteFontSize
            }
            else {
                
                stickyNoteFontSize = kStickyNoteFontSize
            }
            
            if (noteFontColor != nil) {
                
                stickyNoteFontColor = noteFontColor
            }
            else {
                
                stickyNoteFontColor = kDefaultFontColor
            }
            
            
            let rawImage = UIImage(named: stickyNoteType!)
            let textWrittenImage = Common.sharedCommon.textToImage(stickyNoteText!, inImage: rawImage!, atPoint: CGPointMake(5,10),preferredFont:noteFont,preferredFontSize:noteFontSize,preferredFontColor:stickyNoteFontColor,addExpiry:false,expiryDate:nil)
            self.image = textWrittenImage
            
        }
        else {
            
            self.backgroundColor = UIColor.whiteColor()
            let thumbName = "THUMB_" + imageFileName!
            self.imageFileName = imageFileName!
            
            if (self.polaroid == nil) {
                
                let polaroidRect = CGRectInset(self.bounds,10,10)
                
                self.polaroid = UIImageView(frame: polaroidRect)
                self.polaroid!.image = UIImage(named: "nophoto.png")
                self.addSubview(self.polaroid!)
            }
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetImage , body: nil, replace: ["<filename>" :thumbName], requestContentType: kContentTypes.kApplicationJson , completion: { (result, response) -> Void in
                
                if (result == true) {
                    
                    if (response["image"] != nil) {
                        
                        dispatch_async(dispatch_get_main_queue() , { () -> Void in
                            
                            self.imageThumbData = response["image"] as? NSData
                            self.polaroid!.image = UIImage(data: self.imageThumbData!)
                            
                        })
                        
                    }
                    else {
                        
                        print("Image response is nil")
                    }
                }
                
            })
            
            //self.image = UIImage(data: Common.sharedCommon.config!["polaroid"] as! NSData)
        }
        
        self.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "wallNoteTapped:")
        self.addGestureRecognizer(tap)
        self.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
        
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func wallNoteTapped(sender:UITapGestureRecognizer) {
        
       if (wallnoteDelegate != nil && self.isAlreadyBlownUp == false) {
            
            self.isAlreadyBlownUp = true
            wallnoteDelegate!.blowupWallNote(self)
        }
        
    }
    
    func blowUpAttributes(note:WallNote) {
        
        note.isAlreadyBlownUp = true
    }
    
    func resetAttributes(note:WallNote) {
        
        note.isAlreadyBlownUp = false
    }
    
    func removeAttributes(note:WallNote) {
        
        note.removeFromSuperview()
        
    }
    
   override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesBegan(touches, withEvent: event)
    
        let touch  = touches.first
        let movePoint = touch!.locationInView(self.superview)
    
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
        
            self.center = movePoint
        }
    
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        let touch  = touches.first
        let movePoint = touch!.locationInView(self.superview)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.center = movePoint
        }
        
        
    }

    
}
