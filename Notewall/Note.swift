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
    
    init(frame: CGRect, wallnote:WallNote,expiryDate:String) {
        
        super.init(frame: frame)
        
        let rawImage = UIImage(named: wallnote.stickyNoteType!)
        //let noteText = wallnote.stickyNoteDeletionDate! + (wallnote.stickyNoteText! as String)
        let textWrittenImage = Common.sharedCommon.textToImage(wallnote.stickyNoteText! as String, inImage: rawImage!, atPoint: CGPointMake(0, 0),preferredFont: wallnote.stickyNoteFont!,preferredFontSize:wallnote.stickyNoteFontSize, preferredFontColor:wallnote.stickyNoteFontColor,addExpiry:true,expiryDate:expiryDate)
        self.image = textWrittenImage
        self.userInteractionEnabled = true
        self.noteTag = wallnote.noteTag
        
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
