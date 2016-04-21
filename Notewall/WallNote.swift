//
//  WallNote.swift
//  Notewall
//
//  Created by Bharath on 22/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol WallNoteDelegate {
    
    func blowupWallNote(note:WallNote)
    func wallNoteMovedToPoint(note:WallNote,point:CGPoint)
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
    var isPinned = false
    var imageFileName:String?
    var imageThumbData:NSData?
    var followingNoteOwner:Bool?
    var ownerID:String?
    var ownerName:String?
    var pinImage:UIImageView?
    var pinPoint:CGPoint?
    
    init(frame: CGRect,data:Dictionary<String, AnyObject>) {
        
        super.init(frame: frame)
        
        if data["noteProperty"] as? String == "N" {
            
            self.isNote = true
        }
        else {
            
            self.isNote = false
        }
        
        self.isPinned = data["notePinned"] as! Bool
        
        
        if (self.isNote == true) {
            
            self.stickyNoteType = data["noteType"] as? String
            self.stickyNoteText = data["noteText"] as! String
            self.stickyNoteFont = data["noteTextFont"] as? String
            self.stickyNoteFontSize = data["noteTextFontSize"] as? CGFloat
            self.stickyNoteFontColor = Common.sharedCommon.formColorWithRGB(data["noteTextColor"] as! Array<CGFloat>)
            //let rawImage = UIImage(named: self.stickyNoteType!)
            let rawImage = UIImage().noteImage(named: self.stickyNoteType!)
            let textWrittenImage = Common.sharedCommon.textToImage(stickyNoteText!, inImage: rawImage!, atPoint: CGPointMake(5,10),preferredFont:self.stickyNoteFont,preferredFontSize:self.stickyNoteFontSize,preferredFontColor:self.stickyNoteFontColor,addExpiry:false,expiryDate:nil)
            self.image = textWrittenImage
            
        }
        else {
            
            self.imageFileName = data["imageurl"] as? String
            self.backgroundColor = UIColor.whiteColor()
            let thumbName = "THUMB_" + imageFileName!
            
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
                        
                        print(response)
                    }
                }
                
            })
        }
        
        let pinDim = Common.sharedCommon.calculateDimensionForDevice(10)
        self.pinImage = UIImageView(frame: CGRectMake((self.bounds.size.width * 0.5),pinDim,pinDim,pinDim))
        self.pinImage!.image = UIImage(named:"pin.png")
        self.addSubview(self.pinImage!)
        
        if (self.isPinned == false) {
            
            pinImage!.alpha = 0.0
        }
        
        self.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(WallNote.wallNoteTapped(_:)))
        self.addGestureRecognizer(tap)
        self.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
        
        
        self.stickyNoteID = data["noteID"] as? String
        self.favedOwners = data["owners"] as? Array<String>
        self.stickyNoteCreationDate = data["creationDate"] as? String
        self.stickyNoteDeletionDate = data["deletionDate"] as? String
        self.followingNoteOwner = data["followingNoteOwner"] as? Bool
        self.ownerID = data["ownerID"] as? String
        self.ownerName = data["screenName"] as? String
        
        let pinPointData = data["pinPoint"] as! Array<CGFloat>
        let pinPoint = CGPointMake(pinPointData[0],pinPointData[1])
        self.pinPoint = pinPoint
        
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesEnded(touches, withEvent: event)
        
        let touch  = touches.first
        let movePoint = touch!.locationInView(self.superview)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.center = movePoint
            
            if (self.wallnoteDelegate != nil) {
                
                self.wallnoteDelegate!.wallNoteMovedToPoint(self, point: movePoint)
            }
        }
    }
}
