//
//  Note.swift
//  Notewall
//
//  Created by Bharath on 22/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol NoteDelegate {
    
    func removeNoteFromView(note:Note)
    func noteRightSwiped(note:Note)
    func noteDownSwiped(note:Note)
}


class Note:UIImageView {
    
    var noteDelegate:NoteDelegate?
    var noteTag:Int = 0
    var sourceWallNote:WallNote?
    var polaroid:UIImageView?
    var pinImage:UIImageView?
    
    init(frame: CGRect, wallnote:WallNote,expiryDate:String) {
        
        super.init(frame: frame)
        self.sourceWallNote = wallnote
        
        if (self.sourceWallNote!.isNote == true) {
            
            let rawImage = UIImage(named: wallnote.stickyNoteType!)
            //let noteText = wallnote.stickyNoteDeletionDate! + (wallnote.stickyNoteText! as String)
            let textWrittenImage = Common.sharedCommon.textToImage(wallnote.stickyNoteText! as String, inImage: rawImage!, atPoint: CGPointMake(0, 0),preferredFont: wallnote.stickyNoteFont!,preferredFontSize:wallnote.stickyNoteFontSize, preferredFontColor:wallnote.stickyNoteFontColor,addExpiry:true,expiryDate:expiryDate)
            self.image = textWrittenImage
        }
        else {
            
            self.backgroundColor = UIColor.whiteColor()
            let imageFileName = self.sourceWallNote!.imageFileName!
            
            if (self.polaroid == nil) {
                
                let polaroidRect = CGRectInset(self.bounds,10,10)
                
                self.polaroid = UIImageView(frame: polaroidRect)
                self.polaroid!.image = UIImage(named: "nophoto.png")
                self.addSubview(self.polaroid!)
            }
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetImage , body: nil, replace: ["<filename>" :imageFileName], requestContentType: kContentTypes.kApplicationJson , completion: { (result, response) -> Void in
                
                if (result == true) {
                    
                    if (response["image"] != nil) {
                        
                        dispatch_async(dispatch_get_main_queue() , { () -> Void in
                            
                            let imageData = response["image"] as? NSData
                            self.polaroid!.image = UIImage(data: imageData!)
                            
                        })
                        
                    }
                    else {
                        
                        print(response)
                    }
                }
                
            })

            
        }
        
        let pinDim = Common.sharedCommon.calculateDimensionForDevice(30)
        self.pinImage = UIImageView(frame: CGRectMake((self.bounds.size.width * 0.5),Common.sharedCommon.calculateDimensionForDevice(10),pinDim,pinDim))
        self.pinImage!.image = UIImage(named:"pin.png")
        self.addSubview(self.pinImage!)
        
        if (self.sourceWallNote!.isPinned == false) {
            
            pinImage!.alpha = 0.0
        }

        
        self.userInteractionEnabled = true
        self.noteTag = wallnote.noteTag
        self.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
        
        /*let tap = UITapGestureRecognizer(target: self, action: "temp:")
        self.addGestureRecognizer(tap)*/
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: "rightSwiped:")
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.addGestureRecognizer(rightSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: "downSwiped:")
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        self.addGestureRecognizer(downSwipe)
        
        let tap = UITapGestureRecognizer(target: self, action: "noteTapped:")
        self.addGestureRecognizer(tap)
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rightSwiped(sender:Note) {
        
        if (noteDelegate != nil) {
            
            self.noteDelegate!.noteRightSwiped(self)
        }
    }
    
    func downSwiped(sender:Note) {
        
        if (noteDelegate != nil) {
            
            self.noteDelegate!.noteDownSwiped(self)
        }
    }
    
    func noteTapped(sender:Note) {
        
        if (noteDelegate != nil) {
            
            self.noteDelegate!.noteRightSwiped(self)
        }
    }
}
