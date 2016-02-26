//
//  NotewallController.swift
//  Notewall
//
//  Created by Bharath on 21/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics


protocol NoteWallProtocolDelegate {
    
    func handleLogout()
}

class NotewallController:UIViewController, UIScrollViewDelegate, WallNoteDelegate, NoteDelegate,UITextViewDelegate,ComposeDelegate, CloseViewProtocolDelegate, ConfirmProtocolDelegate,OptionsViewProtocolDelegate {
    
    var bgImage:UIImageView?
    var transImage:UIImageView?
    var bgScrollView:UIScrollView?
    var masterView:UIView?
    var blownUpCount:Int = 0
    var blownUpCenterX = UIScreen.mainScreen().bounds.width * 0.5
    let blowUpXOffset:CGFloat = 25.0
    var backgroundImage:UIImageView?
    var backgroundImageIndex = 0
    var dataSourceAPI:kAllowedPaths?
    var backgroundImageName:String?
    var allBlownUpNotes:Array<WallNote> = []
    var notesDataList:Array<Dictionary<String,AnyObject>> = []
    var favButton:UIImageView?
    var followButton:UIImageView?
    var logOutButton:CloseView?
    var noteWallDelegate:NoteWallProtocolDelegate?
    var messageView:UILabel?
    var wallTypeNotifyImage:UIImageView?
    var wallTypeNotifyImageName:String?
    var options:OptionsView?
    var subOptions:OptionsView?
    
    var screenWidth:CGFloat = UIScreen.mainScreen().bounds.size.width
    var screenHeight:CGFloat = UIScreen.mainScreen().bounds.size.height

    
    override func viewDidLoad() {
        

        
        self.view.backgroundColor = UIColor.blackColor()
        self.backgroundImageName = kBackGrounds[backgroundImageIndex]["bg"] as? String
        self.dataSourceAPI = kBackGrounds[backgroundImageIndex]["datasource"] as? kAllowedPaths
        self.wallTypeNotifyImageName = kBackGrounds[backgroundImageIndex]["icon"] as? String
        
        transImage = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        transImage!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        self.view.addSubview(transImage!)
        
       /* self.bgScrollView = UIScrollView(frame: self.view.bounds)
        self.bgScrollView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        self.bgScrollView!.backgroundColor = UIColor.clearColor()
        self.bgScrollView!.contentSize = self.view.bounds.size
        self.bgScrollView!.delegate = self
        self.bgScrollView!.minimumZoomScale = 1.0
        self.bgScrollView!.maximumZoomScale = 4.0
        self.bgScrollView!.canCancelContentTouches = true
        self.view.addSubview(self.bgScrollView!) */

        
        self.loadMainView()
        
    }

    
    
    override func viewDidAppear(animated: Bool) {
        
        //self.loadMainView()
        
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        screenWidth = size.width
        screenHeight = size.height
    }
    
    func loadMainView() {
        
        self.blownUpCount = 0
        self.allBlownUpNotes.removeAll()
        self.allBlownUpNotes = []
        
        //masterView = UIView(frame: CGRectMake(0,0,self.bgScrollView!.contentSize.width,self.bgScrollView!.contentSize.height))
        masterView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        masterView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        masterView!.backgroundColor = UIColor.clearColor()
        //bgScrollView!.addSubview(masterView!)
        self.view.addSubview(masterView!)
        
        backgroundImage = UIImageView(frame: self.masterView!.bounds)
        backgroundImage!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        backgroundImage!.userInteractionEnabled = true
        backgroundImage!.image = UIImage(named: self.backgroundImageName!)
        self.masterView!.addSubview(backgroundImage!)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "changeNoteWall:")
        singleTap.numberOfTapsRequired = 1
        backgroundImage!.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "switchToCompose:")
        doubleTap.numberOfTapsRequired = 2
        backgroundImage!.addGestureRecognizer(doubleTap)
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
       /* if (self.dataSourceAPI == kAllowedPaths.kPathGetFavNotesForOwner) {
            
            self.backgroundImage!.userInteractionEnabled = false
        }
        else {
            
            self.backgroundImage!.userInteractionEnabled = true
        } */
        
        let wallTypeDim = Common.sharedCommon.calculateDimensionForDevice(35)
        wallTypeNotifyImage = UIImageView(frame: CGRectMake(0,0,wallTypeDim,wallTypeDim))
        wallTypeNotifyImage!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, wallTypeDim * 0.5)
        wallTypeNotifyImage!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
        wallTypeNotifyImage!.image = UIImage(named: self.wallTypeNotifyImageName!)
        wallTypeNotifyImage!.userInteractionEnabled = true
        self.masterView!.addSubview(wallTypeNotifyImage!)
        let notifyTap = UITapGestureRecognizer(target: self, action: "showOptionsMenu")
        wallTypeNotifyImage!.addGestureRecognizer(notifyTap)
        
        logOutButton = CloseView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - (1.5 * Common.sharedCommon.calculateDimensionForDevice(30)), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
        logOutButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        logOutButton!.image = UIImage(named: "logout.png")
        logOutButton!.closeViewDelegate = self
        //self.masterView!.addSubview(logOutButton!)
        
       /* let rightSwipe = UISwipeGestureRecognizer(target: self, action: "changeNoteWall:")
        rightSwipe.direction = .Right
        self.masterView!.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: "changeNoteWall:")
        leftSwipe.direction = .Left
        self.masterView!.addGestureRecognizer(leftSwipe) */
        
        //self.showExistingNotes()
        self.fillInDataSource(true)
        
        /*let textWrittenImage = TextNote(frame: CGRectMake(20,20,100,100), withImageName: "noteBlue1.png", withText: "Hello bharath what is this. today is sunday and tmrw is monday", preferredFont: "chalkduster", preferredFontSize: 10.0, preferredFontColor: UIColor.blackColor(), addExpiry: true, expiryDate: "11-02-2016")
        
        self.masterView!.addSubview(textWrittenImage)*/
        
    }
    

    func fillInDataSource(refreshUI:Bool) {
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        Common.sharedCommon.postRequestAndHadleResponse(dataSourceAPI!, body: data, replace: nil,requestContentType:kContentTypes.kApplicationJson) { (result, response) -> Void in
            
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
            favButton = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - favButtonDim - 10, favButtonDim, favButtonDim, favButtonDim))
            favButton!.userInteractionEnabled = true
            self.view.addSubview(favButton!)
            favButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
            
            let tap = UITapGestureRecognizer(target: self, action: "favButtonTapped")
            favButton!.addGestureRecognizer(tap)
        }
        
        if (followButton == nil) {
            
            let followButtonDim = Common.sharedCommon.calculateDimensionForDevice(50)
            followButton = UIImageView(frame: CGRectMake(10, followButtonDim, followButtonDim, followButtonDim))
            followButton!.userInteractionEnabled = true
            self.view.addSubview(followButton!)
            followButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
            
            let tap = UITapGestureRecognizer(target: self, action: "followButtonTapped")
            followButton!.addGestureRecognizer(tap)
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
        self.setFollowImage(note)
        //self.noteLifeLabel!.text = note.stickyNoteDeletionDate!
        
        let v = Note(frame: note.frame, wallnote:note, expiryDate:note.stickyNoteDeletionDate!)
        v.noteDelegate = self
        //v.sourceWallNote = note
        self.view.addSubview(v)
        
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            if (self.blownUpCount == 0) {
                
                self.blownUpCenterX = UIScreen.mainScreen().bounds.size.width * 0.5
                
            }
            else if (self.blownUpCount >= 1) {
                
                    self.blownUpCenterX = self.blownUpCenterX + self.blowUpXOffset
            }
            
                v.frame = CGRectMake(0, 0, Common.sharedCommon.calculateDimensionForDevice(kBlownupNoteDim), Common.sharedCommon.calculateDimensionForDevice(kBlownupNoteDim))
                let center = CGPointMake(self.blownUpCenterX, UIScreen.mainScreen().bounds.size.height * 0.5)
                v.center = center
                //self.bgScrollView!.zoomToRect(self.view.frame, animated: true)
            
                if (v.polaroid != nil) {
                
                    let polRect = CGRectInset(v.bounds,10,10)
                    v.polaroid!.frame = polRect
                
                }
            
            
                self.masterView!.alpha = 0.4
                self.logOutButton!.hidden = true
            
            
            }) { (Bool) -> Void in
                
                self.blownUpCount = self.blownUpCount + 1
                self.allBlownUpNotes.append(note)
                
        }
    }
    
    // Confirm Delegate
    
    func okTapped(sender: ConfirmView, requester: AnyObject?) {
        
        let note = requester as? Note
        
        let removeNote = self.allBlownUpNotes.last!
        let noteID = removeNote.stickyNoteID! as String
        let paramData = NSDictionary(objects: [noteID], forKeys: ["<noteid>"])
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathRemoveNote, body: data, replace: paramData, requestContentType:kContentTypes.kApplicationJson, completion: { (result, response) -> Void in
        
        if (result == true) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
        
        note!.center = CGPointMake(note!.center.x, note!.center.y + UIScreen.mainScreen().bounds.size.height)
        
        
        }) { (Bool) -> Void in
        
        
                note!.sourceWallNote!.removeAttributes(note!.sourceWallNote!)
                self.blowUpRemovalCommonActions(note!)
        
                    }
        
                })
            }
        })
    }
    
    func cancelTapped(sender: ConfirmView, requester:AnyObject?) {
        
        (requester as? Note)!.alpha = 1.0
        self.favButton!.alpha = 1.0
        self.followButton!.alpha = 1.0
        
    }
    
    
    //Note Delegate
    
    func removeNoteFromView(note: Note) {
        
        note.removeFromSuperview()
        self.masterView!.alpha = 1.0
    }
    
    func noteRightSwiped(note: Note) {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
                note.center = CGPointMake(note.center.x + UIScreen.mainScreen().bounds.width, note.center.y)
            
            
            }) { (Bool) -> Void in
                
                note.sourceWallNote!.resetAttributes(note.sourceWallNote!)
                self.blowUpRemovalCommonActions(note)
                
        }
    }
    
    func noteDownSwiped(note: Note) {
        
        note.alpha = 0.5
        
        let confirm = ConfirmView(frame: CGRectMake(0,0,380,200),requester:note)
        confirm.confirmDelegate = self
        confirm.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, -confirm.frame.size.height)
        self.view.addSubview(confirm)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                
                
                confirm.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.5)
                self.favButton!.alpha = 0.0
                self.followButton!.alpha = 0.0
                
                }, completion: { (Bool) -> Void in
                    
            })
        }
        
    }
    
    // Compose Delegate Methods
    
    func postAWallNote(noteType: String?, noteText: String?, noteFont: String?, noteFontSize:CGFloat?, noteFontColor:Array<CGFloat>, noteProperty:String?, imageurl:String? ) {
        
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        var contentType = kContentTypes.kApplicationJson
        var isNote = true
        var data = [String:AnyObject]()
        data = ["ownerid" : ownerID as String, "notetype" : noteType! as String, "notetext" : noteText! as String, "notetextfont" : noteFont! as String, "notetextfontsize" : noteFontSize! as CGFloat, "notepinned": false, "notetextcolor" : noteFontColor,"noteProperty" : noteProperty!, "imageurl" : imageurl!]
        
        if (noteProperty == "P") {
            
           contentType = kContentTypes.kMultipartFormData
            isNote = false
        }
        
       Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathPostNewNote, body: data, replace: nil, requestContentType:contentType) { (result, response) -> Void in
            
            if (result == true) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let newNote = response["data"]![0]
                    let RBGColor = Common.sharedCommon.formColorWithRGB(noteFontColor)
                    let note = WallNote(frame: CGRectMake(100, 30, Common.sharedCommon.calculateDimensionForDevice(kNoteDim), Common.sharedCommon.calculateDimensionForDevice(kNoteDim)), noteType: noteType, noteText: noteText!, noteFont: noteFont, noteFontSize:noteFontSize!, noteFontColor:RBGColor, isNote:isNote, imageFileName:imageurl)
                    note.stickyNoteID = newNote["noteID"] as? String
                    note.favedOwners = newNote["owners"] as? Array<String>
                    note.stickyNoteCreationDate = newNote["creationDate"] as? String
                    note.stickyNoteDeletionDate = newNote["deletionDate"] as? String
                    note.followingNoteOwner = newNote["followingNoteOwner"] as? Bool
                    note.ownerID = newNote["ownerID"] as? String
                    note.ownerName = newNote["screenName"] as? String
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
    
    
    // OPTIONSVIEW DELEGATE METHODS
    
    func handleTappedOptionItem(item: OptionsItem) {
        
        let selectorString = kMenuOptions[item.tag]!["selector"]
        let sel = Selector(selectorString!)
        self.performSelector(sel)
    }
    
    func optionItemLogout() {
        
        if (self.noteWallDelegate != nil) {
            
            self.noteWallDelegate!.handleLogout()
        }
    }
    
    func optionItemGeneral() {
        
        self.showSubOptionsMenu()
    }
    
    
    // Custom Methods
    
    func setFavImage(note:WallNote) {
        
        let favedOwners = note.favedOwners!
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        
        if (note.ownerID != ownerId) {
            
            self.favButton!.alpha = 1.0
            
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
        else {
            
            self.favButton!.alpha = 0.0
        }
        
        
    }
    
    
    func setFollowImage(note:WallNote) {
        
        //let favedOwners = note.favedOwners!
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        
        if (ownerId != note.ownerID) {
            
            self.followButton!.alpha = 1.0
            
            if (note.followingNoteOwner == true) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.followButton!.image = UIImage(named: "unfollow.png")
                })
                
                
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.followButton!.image = UIImage(named: "follow.png")
                })
                
            }
        }
        else {
            
            self.followButton!.alpha = 0.0
        }
        
        
    }
    
    func showExistingNotes() {
        
        
        if (self.notesDataList.count > 0 ){
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(kNoteDim)
            let xPoint = (screenWidth * 0.50) +  CGFloat(Int.random(-50 ... 50))
            var yPoint = (screenHeight * 0.50) + CGFloat(Int.random(-30 ... 30))
            
            if yPoint < 40 {
                
                yPoint = 40
            }
            
            
            let printNote = notesDataList[0]
            var noteProperty = false
            
            if printNote["noteProperty"] as? String == "N" {
                
                noteProperty = true
            }
            
            let noteText = printNote["noteText"] as! String
            let noteTextFont = printNote["noteTextFont"] as! String
            let noteTextFontSize = printNote["noteTextFontSize"] as! CGFloat
            let noteType = printNote["noteType"] as! String
            let noteTextColor = printNote["noteTextColor"] as! Array<CGFloat>
            let imageName = printNote["imageurl"] as! String
            
            
            let note = WallNote(frame: CGRectMake(0,0,dim,dim), noteType:noteType, noteText: noteText, noteFont:noteTextFont, noteFontSize:noteTextFontSize, noteFontColor:Common.sharedCommon.formColorWithRGB(noteTextColor), isNote:noteProperty, imageFileName: imageName)
            note.center = CGPointMake(xPoint,yPoint)
            note.stickyNoteID = printNote["noteID"] as? String
            note.favedOwners = printNote["owners"] as? Array<String>
            note.stickyNoteCreationDate = printNote["creationDate"] as? String
            note.stickyNoteDeletionDate = printNote["deletionDate"] as? String
            note.followingNoteOwner = printNote["followingNoteOwner"] as? Bool
            note.ownerID = printNote["ownerID"] as? String
            note.ownerName = printNote["screenName"] as? String
            note.wallnoteDelegate = self
            self.masterView!.addSubview(note)
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                UIView.animateWithDuration(0.00001, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in

                    
                    note.frame = CGRectMake(note.frame.origin.x, note.frame.origin.y, dim, dim)
                    note.center = CGPointMake(xPoint,yPoint)
                    
                    }, completion: { (Bool) -> Void in
                        
                        if (self.notesDataList.count > 1) {
                            
                            self.notesDataList.removeFirst()
                            self.showExistingNotes()
                        }
                        
                })
                
            }
            
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
        
        for v in self.view.subviews {
            
            if v is Note || v is WallNote || v is ConfirmView {
                
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
        
        if (followButton != nil) {
            
            followButton?.removeFromSuperview()
            followButton = nil
        }
        
      /*  if (noteLifeLabel != nil) {
            
            noteLifeLabel!.removeFromSuperview()
            noteLifeLabel = nil
        } */
    }
    
    func showNoNotes() {
        
        if (messageView == nil) {
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(40)
            messageView = UILabel(frame: CGRectMake(0,(UIScreen.mainScreen().bounds.size.height * 0.5) - (dim * 0.5),UIScreen.mainScreen().bounds.size.width,dim))
            messageView!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
            messageView!.font = UIFont(name: "chalkduster", size: 33.0)
            messageView!.textAlignment = NSTextAlignment.Center
            messageView!.textColor = UIColor.whiteColor()
            messageView!.text = "NO NOTES"
            self.masterView!.addSubview(messageView!)
        }
    }

    
    func switchToCompose(sender:UITapGestureRecognizer) {
        
        if (sender.numberOfTapsRequired == 2 && self.dataSourceAPI != kAllowedPaths.kPathGetFavNotesForOwner) {
            
            if (self.allBlownUpNotes.count == 0) {
                
                let compose:Compose = Compose()
                compose.composeDelegate = self
                self.presentViewController(compose, animated: true) { () -> Void in
                    
                }
            }
            else {
                
                
            }
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
            self.setFollowImage(note!)
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
                
                //self.bgScrollView!.zoomToRect(self.view.frame, animated: true)
                self.masterView!.alpha = 1.0
                self.blownUpCenterX = kScreenWidth * 0.5
                self.favButton!.removeFromSuperview()
                self.followButton!.removeFromSuperview()
                self.favButton = nil
                self.followButton = nil
                //self.noteLifeLabel!.removeFromSuperview()
                //self.noteLifeLabel = nil
                self.allBlownUpNotes.removeAll()
                self.logOutButton!.hidden = false
                
            })
        }
        
    }
    
    func changeNoteWall(sender:UITapGestureRecognizer) {
        
        self.removeExistingNotes()
        self.moveWall(sender.numberOfTapsRequired)
        
    }
    
    /* func moveWall(numberOfTaps:Int) {
        
        if (direction == UISwipeGestureRecognizerDirection.Right) {
            
            self.backgroundImageIndex = self.backgroundImageIndex + 1
        }
        else {
            
            self.backgroundImageIndex = self.backgroundImageIndex - 1
        }
        
        
        if (self.backgroundImageIndex >= kBackGrounds.count) {
            
            self.backgroundImageIndex = 0
        }
        else if (self.backgroundImageIndex < 0 ) {
            
            self.backgroundImageIndex = kBackGrounds.count - 1
        }
        
        self.backgroundImageName = kBackGrounds[self.backgroundImageIndex]["bg"] as? String
        self.dataSourceAPI = kBackGrounds[self.backgroundImageIndex]["datasource"] as? kAllowedPaths
        
        transImage!.image = UIImage(named: self.backgroundImageName!)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            if (direction == UISwipeGestureRecognizerDirection.Right) {
                
                self.masterView!.center = CGPointMake(self.masterView!.center.x + UIScreen.mainScreen().bounds.size.width, self.masterView!.center.y)
            }
            else {
                
                self.masterView!.center = CGPointMake(self.masterView!.center.x - UIScreen.mainScreen().bounds.size.width, self.masterView!.center.y)
            }
            
            
            }) { (Bool) -> Void in
                
                self.masterView!.removeFromSuperview()
                self.masterView = nil
                self.loadMainView()
                self.transImage!.image = nil
                
                
        }
    } */
    
    func moveWall(numberOfTaps:Int) {
        
        self.backgroundImageIndex = self.backgroundImageIndex + 1
        
        
        if (self.backgroundImageIndex >= kBackGrounds.count) {
            
            self.backgroundImageIndex = 0
        }
        else if (self.backgroundImageIndex < 0 ) {
            
            self.backgroundImageIndex = kBackGrounds.count - 1
        }
        
        self.backgroundImageName = kBackGrounds[self.backgroundImageIndex]["bg"] as? String
        self.dataSourceAPI = kBackGrounds[self.backgroundImageIndex]["datasource"] as? kAllowedPaths
        self.wallTypeNotifyImageName = kBackGrounds[self.backgroundImageIndex]["icon"] as? String
        
        transImage!.image = UIImage(named: self.backgroundImageName!)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
               self.masterView!.center = CGPointMake(self.masterView!.center.x + UIScreen.mainScreen().bounds.size.width, self.masterView!.center.y)
            
            }) { (Bool) -> Void in
                
                self.backgroundImage!.removeFromSuperview()
                self.backgroundImage = nil
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
        
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathAddNoteToFav, body: data, replace: paramData,requestContentType:kContentTypes.kApplicationJson) { (result, response) -> Void in
            
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
    
    func followButtonTapped() {
        
        let note = allBlownUpNotes.last!
        let followOwner = note.ownerID! as String
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        let paramData = NSDictionary(objects: [followOwner], forKeys: ["<followownerid>"])
        let data = ["ownerid" : ownerID]
        
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathFollow, body: data, replace: paramData,requestContentType:kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (result == true) {
                
                if (note.followingNoteOwner == true) {
                    
                    note.followingNoteOwner = false
                }
                else {
                    
                    note.followingNoteOwner = true
                }
                
                self.setFollowImage(note)
                self.fillInDataSource(false)
                
            }
        }
        
    }
    
    
    func showOptionsMenu() {
        
        if (subOptions != nil) {
            
            self.showSubOptionsMenu()
        }
        
        if (options == nil) {
            
            let optionsHeight = Common.sharedCommon.calculateDimensionForDevice(40)
            options = OptionsView(frame:CGRectMake(0,-optionsHeight,UIScreen.mainScreen().bounds.size.width,optionsHeight), options:kMenuOptions)
            options!.delegate = self
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    var newFrame = self.options!.frame
                    newFrame.origin.y = 0
                    self.options!.frame = newFrame
                    
                    self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.center.y + newFrame.size.height)
                    
                    }, completion: { (Bool) -> Void in
                        
                })
                
            })
            
            self.view.addSubview(options!)
        }
        else {
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    var newFrame = self.options!.frame
                    newFrame.origin.y = -newFrame.size.height
                    self.options!.frame = newFrame
                    
                    self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.center.y - newFrame.size.height)
                    
                    }, completion: { (Bool) -> Void in
                        self.options?.removeFromSuperview()
                        self.options = nil
                })
                
            })

        }
        
    }
    
    
    func showSubOptionsMenu() {
        
        if (subOptions == nil) {
            
            let optionsHeight = Common.sharedCommon.calculateDimensionForDevice(40)
            subOptions = OptionsView(frame:CGRectMake(0,options!.frame.origin.y ,UIScreen.mainScreen().bounds.size.width,optionsHeight), options:kGeneralMenuOptions)
            subOptions!.delegate = self
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    var newFrame = self.subOptions!.frame
                    newFrame.origin.y = self.options!.frame.origin.y + self.options!.frame.size.height
                    self.subOptions!.frame = newFrame
                    
                    self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.center.y + newFrame.size.height)
                    
                    }, completion: { (Bool) -> Void in
                        
                })
                
            })
            
            self.view.addSubview(subOptions!)
            self.view.insertSubview(subOptions!, belowSubview: options!)
            
        }
        else {
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    var newFrame = self.subOptions!.frame
                    newFrame.origin.y = -newFrame.size.height
                    self.subOptions!.frame = newFrame
                    
                    self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.center.y - newFrame.size.height)
                    
                    }, completion: { (Bool) -> Void in
                        self.subOptions?.removeFromSuperview()
                        self.subOptions = nil
                })
                
            })
            
        }
        
    }

    
}
