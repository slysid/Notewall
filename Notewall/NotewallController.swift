//
//  NotewallController.swift
//  Notewall
//
//  Created by Bharath on 21/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol NoteWallProtocolDelegate {
    
    func handleLogout()
}

class NotewallController:UIViewController, UIScrollViewDelegate, WallNoteDelegate, NoteDelegate,UITextViewDelegate,ComposeDelegate, CloseViewProtocolDelegate {
    
    var bgImage:UIImageView?
    var transImage:UIImageView?
    var bgScrollView:UIScrollView?
    var masterView:UIView?
    var blownUpCount:Int = 0
    var blownUpCenterX = kScreenWidth * 0.5
    let blowUpXOffset:CGFloat = 25.0
    var backgroundImage:UIImageView?
    var backgroundImageIndex = 0
    var dataSourceAPI:kAllowedPaths?
    var backgroundImageName:String?
    var allNotes:Array<WallNote> = []
    var allBlownUpNotes:Array<WallNote> = []
    var allNotesCount = 75
    var notesDataList:Array<Dictionary<String,AnyObject>> = []
    var favButton:UIImageView?
    var logOutButton:CloseView?
    var noteWallDelegate:NoteWallProtocolDelegate?
    var messageView:UILabel?

    
    override func viewDidLoad() {
        
        
        self.view.backgroundColor = UIColor.blackColor()
        self.backgroundImageName = kBackGrounds[backgroundImageIndex]["bg"] as? String
        self.dataSourceAPI = kBackGrounds[backgroundImageIndex]["datasource"] as? kAllowedPaths
        
        transImage = UIImageView(frame: CGRectMake(0, 0, kScreenWidth, kScreenHeight))
        self.view.addSubview(transImage!)
        
        self.bgScrollView = UIScrollView(frame: self.view.bounds)
        self.bgScrollView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        self.bgScrollView!.backgroundColor = UIColor.clearColor()
        self.bgScrollView!.contentSize = CGSizeMake(kScreenWidth, kScreenHeight)
        self.bgScrollView!.delegate = self
        self.bgScrollView!.minimumZoomScale = 1.0
        self.bgScrollView!.maximumZoomScale = 4.0
        self.bgScrollView!.canCancelContentTouches = true
        self.view.addSubview(self.bgScrollView!)
        
        self.loadMainView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //self.loadMainView()
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func loadMainView() {
        
        self.blownUpCount = 0
        self.blownUpCenterX = kScreenWidth * 0.5
        
        masterView = UIView(frame: CGRectMake(0,0,self.bgScrollView!.contentSize.width,self.bgScrollView!.contentSize.height))
        masterView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        masterView!.backgroundColor = UIColor.clearColor()
        bgScrollView!.addSubview(masterView!)
        
        backgroundImage = UIImageView(frame: self.masterView!.bounds)
        backgroundImage!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        let newNoteTap = UITapGestureRecognizer(target: self, action: "switchToCompose:")
        backgroundImage!.userInteractionEnabled = true
        backgroundImage!.addGestureRecognizer(newNoteTap)
        backgroundImage!.image = UIImage(named: self.backgroundImageName!)
        self.masterView!.addSubview(backgroundImage!)
        
        if (self.dataSourceAPI == kAllowedPaths.kPathGetFavNotesForOwner) {
            
            self.backgroundImage!.userInteractionEnabled = false
        }
        else {
            
            self.backgroundImage!.userInteractionEnabled = true
        }
        
        logOutButton = CloseView(frame: CGRectMake(kScreenWidth - (1.5 * Common.sharedCommon.calculateDimensionForDevice(30)), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
        logOutButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        logOutButton!.image = UIImage(named: "logout.png")
        logOutButton!.closeViewDelegate = self
        self.masterView!.addSubview(logOutButton!)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: "changeNoteWall")
        downSwipe.direction = .Down
        self.masterView!.addGestureRecognizer(downSwipe)
        
        //self.showExistingNotes()
        self.fillInDataSource(true)
        
    }
    
    func fillInDataSource(refreshUI:Bool) {
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        Common.sharedCommon.postRequestAndHadleResponse(dataSourceAPI!, body: data, replace: nil) { (result, response) -> Void in
            
            if (result == true) {
                
                let respData = response.objectForKey("data")
                self.notesDataList = respData! as! Array<Dictionary<String, AnyObject>>
                
                if (refreshUI == true) {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.showExistingNotes()
                    })
                    
                }
                
            }
            else {
                
                Common.sharedCommon.showMessageViewWithMessage(self, message: "Network Error",startTimer:false)
            }
        }
    }
    
    //Scrollview Delegate methods
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return self.masterView!
        
    }
    
    // WallNote Delegate
    
    func blowupWallNote(note: WallNote) {
        
        if (favButton == nil) {
            
            let favButtonDim = Common.sharedCommon.calculateDimensionForDevice(50)
            favButton = UIImageView(frame: CGRectMake(kScreenWidth - ( 1.5 * favButtonDim), favButtonDim, favButtonDim, favButtonDim))
            favButton!.userInteractionEnabled = true
            self.view.addSubview(favButton!)
            favButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
            
            let tap = UITapGestureRecognizer(target: self, action: "favButtonTapped")
            favButton!.addGestureRecognizer(tap)
        }
        
       /* if (noteLifeLabel == nil) {
            
            let width = Common.sharedCommon.calculateDimensionForDevice(100)
            let height = Common.sharedCommon.calculateDimensionForDevice(50)
            self.noteLifeLabel = UILabel(frame: CGRectMake(0,0,width,height))
            self.noteLifeLabel!.center = CGPointMake(kScreenWidth - (width * 0.5), kScreenHeight - (1.5 * height))
            self.noteLifeLabel!.backgroundColor = UIColor.clearColor()
            self.noteLifeLabel!.textAlignment = NSTextAlignment.Left
            self.noteLifeLabel!.font = UIFont(name: "chalkduster", size: 11.0)
            self.noteLifeLabel!.textColor = UIColor.whiteColor()
            self.masterView!.addSubview(self.noteLifeLabel!)
        } */
        
        self.setFavImage(note)
        //self.noteLifeLabel!.text = note.stickyNoteDeletionDate!
        
        let v = Note(frame: note.frame, wallnote:note, expiryDate:note.stickyNoteDeletionDate!)
        v.noteDelegate = self
        v.sourceWallNote = note
        self.view.addSubview(v)
        
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
                if (self.blownUpCount >= 1) {
                
                    self.blownUpCenterX = self.blownUpCenterX + self.blowUpXOffset
                }
            
                v.frame = CGRectMake(0, 0, Common.sharedCommon.calculateDimensionForDevice(kBlownupNoteDim), Common.sharedCommon.calculateDimensionForDevice(kBlownupNoteDim))
                let center = CGPointMake(self.blownUpCenterX, kScreenHeight * 0.5)
                v.center = center
                //self.bgScrollView!.zoomToRect(self.view.frame, animated: true)
                self.masterView!.alpha = 0.4
                self.logOutButton!.hidden = true
            
            
            }) { (Bool) -> Void in
                
                self.blownUpCount = self.blownUpCount + 1
                self.allBlownUpNotes.append(note)
                
        }
    }
    
    //Note Delegate
    
    func removeNoteFromView(note: Note) {
        
        note.removeFromSuperview()
        self.masterView!.alpha = 1.0
    }
    
    func noteRightSwiped(note: Note) {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
                note.center = CGPointMake(note.center.x + kScreenWidth, note.center.y)
            
            
            }) { (Bool) -> Void in
                
                note.sourceWallNote!.resetAttributes(note.sourceWallNote!)
                self.blowUpRemovalCommonActions(note)
                
        }
    }
    
    func noteDownSwiped(note: Note) {
        
        let removeNote = self.allBlownUpNotes.last!
        let noteID = removeNote.stickyNoteID! as String
        let paramData = NSDictionary(objects: [noteID], forKeys: ["<noteid>"])
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathRemoveNote, body: data, replace: paramData, completion: { (result, response) -> Void in
            
            if (result == true) {
            
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    
                    note.center = CGPointMake(note.center.x, note.center.y + kScreenHeight)
                    
                    
                    }) { (Bool) -> Void in
                        
                        
                        note.sourceWallNote!.removeAttributes(note.sourceWallNote!)
                        self.blowUpRemovalCommonActions(note)
                        
                }

             })
          }
       })
        
    }
    
    // Compose Delegate Methods
    
    func postAWallNote(noteType: String?, noteText: String, noteFont: String, noteFontSize:CGFloat, noteFontColor:Array<CGFloat>) {
        
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        var data = [String:AnyObject]()
        data = ["ownerid" : ownerID as String, "notetype" : noteType! as String, "notetext" : noteText as String, "notetextfont" : noteFont as String, "notetextfontsize" : noteFontSize as CGFloat, "notepinned": false, "notetextcolor" : noteFontColor]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathPostNewNote, body: data, replace: nil) { (result, response) -> Void in
            
            if (result == true) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let newNote = response["data"]![0]
                    let RBGColor = Common.sharedCommon.formColorWithRGB(noteFontColor)
                    let note = WallNote(frame: CGRectMake(100, 30, Common.sharedCommon.calculateDimensionForDevice(kNoteDim), Common.sharedCommon.calculateDimensionForDevice(kNoteDim)), noteType: noteType, noteText: noteText, noteFont: noteFont, noteFontSize:noteFontSize, noteFontColor:RBGColor)
                    note.stickyNoteID = newNote["noteID"] as? String
                    note.favedOwners = newNote["owners"] as? Array<String>
                    note.stickyNoteCreationDate = newNote["creationDate"] as? String
                    note.stickyNoteDeletionDate = newNote["deletionDate"] as? String
                    note.wallnoteDelegate = self
                    self.masterView!.addSubview(note)

                    
                })
            }
            else {
                
                print(response)
            }
            
            
        }
        
    }
    
    // CloseView Delegate Methods
    
    func handleCloseViewTap() {
        
        if (self.noteWallDelegate != nil) {
            
            self.noteWallDelegate!.handleLogout()
        }
    }
    
    
    // Custom Methods
    
    func setFavImage(note:WallNote) {
        
        let favedOwners = note.favedOwners!
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        if (favedOwners.contains(ownerId)) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.favButton!.image = UIImage(named: "removefav.png")
            })
            
            
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.favButton!.image = UIImage(named: "addfav.png")
            })

        }
    }
    
    func showExistingNotes() {
        
        if (self.notesDataList.count > 0 ){
            
            
            let xPoint = (UIScreen.mainScreen().bounds.width * 0.45) +  CGFloat(Int.random(-100 ... 50))
            var yPoint = (UIScreen.mainScreen().bounds.height * 0.50) + CGFloat(Int.random(-100 ... 100))
            
            if yPoint < 40 {
                
                yPoint = 40
            }
            
            let printNote = notesDataList[0]
            let noteText = printNote["noteText"] as! String
            let noteTextFont = printNote["noteTextFont"] as! String
            let noteTextFontSize = printNote["noteTextFontSize"] as! CGFloat
            let noteType = printNote["noteType"] as! String
            let noteTextColor = printNote["noteTextColor"] as! Array<CGFloat>
            
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(kNoteDim)
            let note = WallNote(frame: CGRectMake(xPoint,yPoint,0,0), noteType:noteType, noteText: noteText, noteFont:noteTextFont, noteFontSize:noteTextFontSize, noteFontColor:Common.sharedCommon.formColorWithRGB(noteTextColor))
            note.stickyNoteID = printNote["noteID"] as? String
            note.favedOwners = printNote["owners"] as? Array<String>
            note.stickyNoteCreationDate = printNote["creationDate"] as? String
            note.stickyNoteDeletionDate = printNote["deletionDate"] as? String
            note.wallnoteDelegate = self
            self.masterView!.addSubview(note)
            
            UIView.animateWithDuration(0.00001, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                note.frame = CGRectMake(xPoint, yPoint, dim, dim)
                
                }, completion: { (Bool) -> Void in
                    
                    if (self.notesDataList.count > 1) {
                        
                        self.notesDataList.removeFirst()
                        self.showExistingNotes()
                    }
                    
            })
            
        }
        else {
            
            
            self.showNoNotes()
        }
        
    }
    
    func removeExistingNotes() {
        
        self.masterView!.alpha = 1.0
        for v in self.masterView!.subviews {
            
            if v is Note || v is WallNote {
                
                v.removeFromSuperview()
            }
            
        }
        
        if (messageView != nil) {
            
            messageView!.removeFromSuperview()
            messageView = nil
        }
        
        if (favButton != nil) {
            
            favButton?.removeFromSuperview()
            favButton = nil
        }
        
      /*  if (noteLifeLabel != nil) {
            
            noteLifeLabel!.removeFromSuperview()
            noteLifeLabel = nil
        } */
    }
    
    func showNoNotes() {
        
        if (messageView == nil) {
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(40)
            messageView = UILabel(frame: CGRectMake(0,(kScreenHeight * 0.5) - (dim * 0.5),kScreenWidth,dim))
            messageView!.font = UIFont(name: "chalkduster", size: 33.0)
            messageView!.textAlignment = NSTextAlignment.Center
            messageView!.textColor = UIColor.whiteColor()
            messageView!.text = "NO NOTES"
            self.masterView!.addSubview(messageView!)
        }
    }

    
    func switchToCompose(sender:UIImageView) {
        
        if (self.allBlownUpNotes.count == 0) {
            
            let compose:Compose = Compose()
            compose.composeDelegate = self
            self.presentViewController(compose, animated: true) { () -> Void in
                
            }
        }
        else {
            
           
        }
        
    }
    
    func blowUpRemovalCommonActions(note:Note) {
        
        note.removeFromSuperview()
        let index = allBlownUpNotes.indexOf(note.sourceWallNote!)
        allBlownUpNotes.removeAtIndex(index!)
        self.blownUpCount = self.blownUpCount - 1
        self.blownUpCenterX = self.blownUpCenterX - self.blowUpXOffset
        
        if (self.allBlownUpNotes.count >= 1) {
            
            let note = self.allBlownUpNotes.last
            self.setFavImage(note!)
        }
        
        if (self.dataSourceAPI == kAllowedPaths.kPathGetFavNotesForOwner) {
            
            let ownerID = Common.sharedCommon.config!["ownerId"] as! String
            if (note.sourceWallNote!.favedOwners!.contains(ownerID) == false) {
                
                note.sourceWallNote!.removeFromSuperview()
            }
            
            if (self.notesDataList.count == 0) {
                
                self.showNoNotes()
            }
        }
        
        if (self.blownUpCount == 0) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.bgScrollView!.zoomToRect(self.view.frame, animated: true)
                self.masterView!.alpha = 1.0
                self.blownUpCenterX = kScreenWidth * 0.5
                self.favButton!.removeFromSuperview()
                self.favButton = nil
                //self.noteLifeLabel!.removeFromSuperview()
                //self.noteLifeLabel = nil
                self.allBlownUpNotes.removeAll()
                self.logOutButton!.hidden = false
                
            })
        }
    }
    
    func changeNoteWall() {
        
        self.removeExistingNotes()
        self.moveWall()
        
    }
    
    func moveWall() {
        
        self.backgroundImageIndex = self.backgroundImageIndex + 1
        if (self.backgroundImageIndex >= kBackGrounds.count) {
            
            self.backgroundImageIndex = 0
        }
        self.backgroundImageName = kBackGrounds[self.backgroundImageIndex]["bg"] as? String
        self.dataSourceAPI = kBackGrounds[self.backgroundImageIndex]["datasource"] as? kAllowedPaths
        
        transImage!.image = UIImage(named: self.backgroundImageName!)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.masterView!.center = CGPointMake(self.masterView!.center.x, self.masterView!.center.y + kScreenHeight)
            
            }) { (Bool) -> Void in
                
                self.masterView!.removeFromSuperview()
                self.masterView = nil
                self.loadMainView()
                self.transImage!.image = nil
                
                
        }
    }
    
    func favButtonTapped() {
        
        let note = allBlownUpNotes.last!
        let noteID = note.stickyNoteID! as String
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        let paramData = NSDictionary(objects: [noteID], forKeys: ["<noteid>"])
        
        let data = ["ownerid" : ownerID]
        
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathAddNoteToFav, body: data, replace: paramData) { (result, response) -> Void in
            
            if (result == true) {
                
                
                if (note.favedOwners!.contains(ownerID) == true) {
                    
                    let removeIndex = note.favedOwners!.indexOf(ownerID)
                    note.favedOwners!.removeAtIndex(removeIndex!)
                }
                else {
                    
                    note.favedOwners!.append(ownerID)
                }
                
                self.setFavImage(note)
                self.fillInDataSource(false)
                
            }
        }
        
    }
    
}
