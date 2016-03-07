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

class NotewallController:UIViewController, UIScrollViewDelegate, WallNoteDelegate, NoteDelegate,UITextViewDelegate,ComposeDelegate, CloseViewProtocolDelegate, ConfirmProtocolDelegate,OptionsViewProtocolDelegate,ProfileViewProtocolDelegate, OptionsOptionViewProtocolDelegate {
    
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
    var noteOwnerLabel:UILabel?
    var logOutButton:CloseView?
    var noteWallDelegate:NoteWallProtocolDelegate?
    var messageView:UILabel?
    var wallTypeNotifyImage:UIImageView?
    var wallTypeNotifyImageName:String?
    var options:OptionsView?
    var subOptions:OptionsView?
    var profileView:ProfileView?
    var optionsOptionView:OptionsOptionView?
    var aboutView:AboutView?
    var filledInOptionsView:UIView? = nil
    var activity:UIActivityIndicatorView? = nil
    
    var screenWidth:CGFloat = UIScreen.mainScreen().bounds.size.width
    var screenHeight:CGFloat = UIScreen.mainScreen().bounds.size.height

    
    override func viewDidLoad() {
        

        
        //self.view.backgroundColor = UIColor(red: CGFloat(195.0/255.0), green: CGFloat(58.0/255.0), blue: (58.0/255.0), alpha: 1.0)
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

        
        self.loadMainView(resetDataSource:true)
        
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
    
    override func shouldAutorotate() -> Bool {
        
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if (self.options != nil) {
            
            return UIInterfaceOrientationMask.Portrait
        }
        
        return UIInterfaceOrientationMask.All
    }

    
    func loadMainView( resetDataSource resetDataSource:Bool) {
        
        self.blownUpCount = 0
        self.allBlownUpNotes.removeAll()
        self.allBlownUpNotes = []
        
        if (masterView == nil) {
            
            //masterView = UIView(frame: CGRectMake(0,0,self.bgScrollView!.contentSize.width,self.bgScrollView!.contentSize.height))
            masterView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
            masterView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
            masterView!.backgroundColor = UIColor.blackColor()
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
            
            
            let wallTypeDim = Common.sharedCommon.calculateDimensionForDevice(35)
            wallTypeNotifyImage = UIImageView(frame: CGRectMake(0,0,wallTypeDim,wallTypeDim))
            wallTypeNotifyImage!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, wallTypeDim * 0.5)
            wallTypeNotifyImage!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
            wallTypeNotifyImage!.image = UIImage(named: self.wallTypeNotifyImageName!)
            wallTypeNotifyImage!.userInteractionEnabled = true
            self.view.addSubview(wallTypeNotifyImage!)
            let notifyTap = UITapGestureRecognizer(target: self, action: "showOptionsMenu")
            wallTypeNotifyImage!.addGestureRecognizer(notifyTap)
            
            logOutButton = CloseView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - (1.5 * Common.sharedCommon.calculateDimensionForDevice(30)), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
            logOutButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
            logOutButton!.image = UIImage(named: "logout.png")
            logOutButton!.closeViewDelegate = self
            //self.masterView!.addSubview(logOutButton!)
            
        }
        
        if (activity == nil) {
            
            activity = UIActivityIndicatorView(frame: CGRectMake(0,0,30,30))
            activity!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.10)
            self.masterView!.addSubview(activity!)
        }
        
        if (resetDataSource == true) {
        
            if (self.dataSourceAPI! == kAllowedPaths.kPathGetFavNotesForOwner) {
                
                self.fillInDataSource(true,ignoreCache:true)
            }
            else {
                
                self.fillInDataSource(true,ignoreCache:false)
            }
        }
        else {
            
            self.showExistingNotes()
        }
        
        
        
    }
    
    func activityStartAnimating() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.activity!.startAnimating()
        }
    }
    
    func activityStopAnimating() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.activity!.stopAnimating()
        }
    }
    
    func filterResults() {
        
        let ownerid = Common.sharedCommon.config!["ownerId"] as! String
        
        let onlyOwnerPredicate = NSPredicate(format: "ownerID = %@", ownerid)
        CacheManager.sharedCacheManager.myNotesDataList = ((CacheManager.sharedCacheManager.allNotesDataList as NSArray).filteredArrayUsingPredicate(onlyOwnerPredicate) as? Array<Dictionary<String,AnyObject>>)!
        
        let onlyOwnerFavPredicate = NSPredicate(format: "owners contains[c] %@", ownerid)
        CacheManager.sharedCacheManager.myFavsNotesDataList = ((CacheManager.sharedCacheManager.allNotesDataList as NSArray).filteredArrayUsingPredicate(onlyOwnerFavPredicate) as? Array<Dictionary<String,AnyObject>>)!
        
    }
    

    func fillInDataSource(refreshUI:Bool,ignoreCache:Bool) {
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        self.activityStartAnimating()
        
        CacheManager.sharedCacheManager.decideOnCall(ignoreCache) { (result, response) -> () in
            
            if (result == true) {
                
                Common.sharedCommon.postRequestAndHadleResponse(self.dataSourceAPI!, body: data, replace: nil,requestContentType:kContentTypes.kApplicationJson) { (result, response) -> Void in
                    
                    self.activityStopAnimating()
                    
                    if (result == true) {
                        
                        if (response["data"]!["error"] != nil) {
                            
                            Common.sharedCommon.showMessageViewWithMessage(self.view, message: response["data"]!["error"] as! String,startTimer:false)
                            
                        }
                        else {
                            
                            
                            let respData = response.objectForKey("data")
                            self.notesDataList = respData! as! Array<Dictionary<String, AnyObject>>
                            
                            if (self.dataSourceAPI! == kAllowedPaths.kPathGetAllNotes) {
                                
                                CacheManager.sharedCacheManager.allNotesDataList = respData! as! Array<Dictionary<String, AnyObject>>
                                self.filterResults()
                            }
                            
                            
                            if (refreshUI == true) {
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    
                                    self.showExistingNotes()
                                })
                                
                            }
                            
                        }
                        
                    }
                    else {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Network Error",startTimer:false)
                        print(response)
                    }
                }
                
            }
            else {
                
                switch self.dataSourceAPI! {
                    
                case kAllowedPaths.kPathGetAllNotes:
                        self.notesDataList = CacheManager.sharedCacheManager.allNotesDataList
                case kAllowedPaths.kPathGetNotesForOwner:
                        self.notesDataList = CacheManager.sharedCacheManager.myNotesDataList
                case kAllowedPaths.kPathGetFavNotesForOwner:
                        self.notesDataList = CacheManager.sharedCacheManager.myFavsNotesDataList
                default:
                        break
                    
                }
                
                if (refreshUI == true) {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.showExistingNotes()
                    })
                    
                }
                
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
        
        
        if (noteOwnerLabel == nil) {
            
            let followButtonDim = Common.sharedCommon.calculateDimensionForDevice(50)
            noteOwnerLabel = UILabel(frame: CGRectMake(0, 0, Common.sharedCommon.calculateDimensionForDevice(100), followButtonDim))
            noteOwnerLabel!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5,followButton!.center.y)
            noteOwnerLabel!.textAlignment = NSTextAlignment.Center
            noteOwnerLabel!.font = UIFont(name: "Roboto", size: 24)
            noteOwnerLabel!.textColor = UIColor.whiteColor()
            self.view.addSubview(noteOwnerLabel!)
            noteOwnerLabel!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
        }
        
        self.noteOwnerLabel!.text = note.ownerName
        self.setFavImage(note)
        self.setFollowImage(note)
        
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
                let center = CGPointMake(self.blownUpCenterX, UIScreen.mainScreen().bounds.size.height * 0.60)
                v.center = center
                //self.bgScrollView!.zoomToRect(self.view.frame, animated: true)
            
                if (v.polaroid != nil) {
                
                    let polRect = CGRectInset(v.bounds,10,10)
                    v.polaroid!.frame = polRect
                
                }
            
            
                self.masterView!.alpha = 0.6
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
        self.noteOwnerLabel!.alpha = 1.0
        
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
                self.noteOwnerLabel!.alpha = 0.0
                
                }, completion: { (Bool) -> Void in
                    
            })
        }
        
    }
    
    // Compose Delegate Methods
    
    func postAWallNote(noteType: String?, noteText: String?, noteFont: String?, noteFontSize:CGFloat?, noteFontColor:Array<CGFloat>, noteProperty:String?, imageurl:String?, isPinned:Bool) {
        
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        var contentType = kContentTypes.kApplicationJson
        var isNote = true
        var data = [String:AnyObject]()
        data = ["ownerid" : ownerID as String, "notetype" : noteType! as String, "notetext" : noteText! as String, "notetextfont" : noteFont! as String, "notetextfontsize" : noteFontSize! as CGFloat, "notepinned": isPinned, "notetextcolor" : noteFontColor,"noteProperty" : noteProperty!, "imageurl" : imageurl!]
        
        if (noteProperty == "P") {
            
           contentType = kContentTypes.kMultipartFormData
            isNote = false
        }
        
       Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathPostNewNote, body: data, replace: nil, requestContentType:contentType) { (result, response) -> Void in
            
            if (result == true) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let newNote = response["data"]![0]
                    let RBGColor = Common.sharedCommon.formColorWithRGB(noteFontColor)
                    let note = WallNote(frame: CGRectMake(100, 30, Common.sharedCommon.calculateDimensionForDevice(kNoteDim), Common.sharedCommon.calculateDimensionForDevice(kNoteDim)), noteType: noteType, noteText: noteText!, noteFont: noteFont, noteFontSize:noteFontSize!, noteFontColor:RBGColor, isNote:isNote, imageFileName:imageurl, isPinned:isPinned)
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
    
    func handleTappedOptionItem(item: OptionsItem, options: Dictionary<Int, Dictionary<String, String>>) {
        
        for opt in self.options!.subviews {
            
            if (opt is OptionsItem) {
                
                (opt as! OptionsItem).titleLabel!.textColor = UIColor.whiteColor()
            }
        }
        
        if (self.subOptions != nil) {
            
            for opt in self.subOptions!.subviews {
                
                if (opt is OptionsItem) {
                    
                    (opt as! OptionsItem).titleLabel!.textColor = UIColor.whiteColor()
                }
            }
            
        }
        
        
        
        item.titleLabel!.textColor = UIColor.blackColor()
        
        let selectorString = options[item.tag]!["selector"]
        let sel = Selector(selectorString!)
        self.performSelector(sel)
    }
    
    func optionItemLogout() {
        
        if (self.noteWallDelegate != nil) {
            
            self.noteWallDelegate!.handleLogout()
        }
    }
    
    func optionItemGeneral() {
        
        self.animateView(nil)
        self.showSubOptionsMenu()
    }
    
    func optionItemProfile() {
        
        if (profileView != filledInOptionsView) {
            
            profileView = nil
        }
        
        
        if (profileView == nil) {
            
            //let yPos = self.wallTypeNotifyImage!.frame.origin.y + self.wallTypeNotifyImage!.frame.size.height
            //profileView = ProfileView(frame: CGRectMake(0,-UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos))
            profileView = ProfileView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
            profileView!.profileViewDelegate = self
            
            self.view.addSubview(profileView!)
            self.view.insertSubview(self.wallTypeNotifyImage! , aboveSubview: self.profileView!)
            self.view.insertSubview(profileView!, belowSubview: subOptions!)
            self.animateView(profileView!)
            
        }
        
    }
    
    func optionItemOptions() {
        
        if (optionsOptionView != filledInOptionsView) {
            
            optionsOptionView = nil
        }
        
        if (optionsOptionView == nil) {
            
            //let yPos = self.wallTypeNotifyImage!.frame.origin.y + self.wallTypeNotifyImage!.frame.size.height
            //optionsOptionView = OptionsOptionView(frame: CGRectMake(0,-UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos))
            optionsOptionView = OptionsOptionView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
            self.optionsOptionView!.optionsOptionsDelegate = self
            
            self.view.addSubview(optionsOptionView!)
            self.view.insertSubview(self.wallTypeNotifyImage! , aboveSubview: self.optionsOptionView!)
            self.view.insertSubview(optionsOptionView!, belowSubview: subOptions!)
            self.animateView(optionsOptionView!)
            
        }

    }
    
    func optionItemAbout() {
        
        if (aboutView != filledInOptionsView) {
            
            aboutView = nil
        }
        
        if (aboutView == nil) {
            
            //let yPos = self.wallTypeNotifyImage!.frame.origin.y + self.wallTypeNotifyImage!.frame.size.height
            //aboutView = AboutView(frame: CGRectMake(0,-UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos))
            aboutView = AboutView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height))
            
            self.view.addSubview(aboutView!)
            self.view.insertSubview(self.wallTypeNotifyImage! , aboveSubview: self.aboutView!)
            self.view.insertSubview(aboutView!, belowSubview: subOptions!)
            self.animateView(aboutView!)
            
        }

    }
    
    func animateView(v:UIView?) {
        
        
        UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            if (self.filledInOptionsView != nil) {
                
                self.filledInOptionsView!.alpha = 0.0
            }
            
            if (v != nil) {
                
                let yPos = self.wallTypeNotifyImage!.frame.origin.y + self.wallTypeNotifyImage!.frame.size.height
                v!.center = CGPointMake(v!.center.x,(UIScreen.mainScreen().bounds.size.height * 0.5) + (yPos * 0.5))
                
            }
            
            }) { (Bool) -> Void in
                
                if (self.filledInOptionsView != nil) {
                    
                    self.filledInOptionsView!.removeFromSuperview()
                    self.filledInOptionsView = nil
                }
                
                if (v != nil) {
                    
                    self.filledInOptionsView = v!
                }
        }
    }
    
    
    // PROFILEVIEW DELEGATE METHODS
    
    
    func updateScreenName(name: String, completion: (Bool,String) -> Void) {
        
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        let data = ["ownerid" : ownerId,"screenname":name]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathUpdateScreenName , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (result == true) {
                
                let errMsg = response.objectForKey("data")!.objectForKey("error")
                
                if(errMsg != nil) {
                    
                    let msg = response["data"]!["error"] as? String
                    if (msg!.rangeOfString("duplicate") != nil) {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self.view, message: "ScreenName Exists", startTimer: true)
                    }
                    
                    completion(false,msg!)
                }
                else {
                    
                    Common.sharedCommon.config!["screenname"] = name
                    completion(true,"OK")
                }
                
                
            }
            else {
                
                completion(false,"Unknown Error")
            }
        }
        
    }
    
    func updatePassword(oldpassword: String, newpassword: String, completion: (Bool, String) -> Void) {
        
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        let data = ["ownerid" : ownerId,"oldpassword":oldpassword,"newpassword":newpassword]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathUpdatePaswword, body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            
            if (result == true) {
                
                let errMsg = response.objectForKey("data")!.objectForKey("error")
                
                if(errMsg != nil) {
                    
                    let msg = response["data"]!["error"] as? String
                    completion(false,msg!)
                }
                else {
                    
                    completion(true,"OK")
                }
            }
            else {
                
                completion(false,"Unknown Error")
            }
        }
        
    }
    
    
    // OPTIONSOPTIONS DELEGATE METHOD
    
    func followingUpdated(followingID: String) {
        
        self.fillInDataSource(false, ignoreCache: true)
        
        for v in self.masterView!.subviews {
            
            if v is WallNote {
                
                if ((v as? WallNote)!.ownerID == followingID) {
                    
                    (v as? WallNote)!.followingNoteOwner = false
                }
            }
        }
    }
    
    func showNotesForSelectedFollowingOwner(dataList: NSArray) {
        
        self.backgroundImageIndex = self.backgroundImageIndex - 1
        
        self.notesDataList = dataList as! Array<Dictionary<String, AnyObject>>
        
        self.showOptionsMenu()
        
        self.backgroundImageName = "bg4.jpg"
        self.dataSourceAPI = kBackGrounds[0]["datasource"] as? kAllowedPaths
        self.wallTypeNotifyImageName = kBackGrounds[0]["icon"] as? String
        
        transImage!.image = nil
        transImage!.image = UIImage(named: self.backgroundImageName!)
        
        self.backgroundImage!.removeFromSuperview()
        self.backgroundImage = nil
        self.masterView!.removeFromSuperview()
        self.masterView = nil
        self.wallTypeNotifyImage!.removeFromSuperview()
        self.wallTypeNotifyImage = nil
        self.loadMainView(resetDataSource:false)
        self.transImage!.image = nil
        
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
            let isPinned = printNote["notePinned"] as! Bool
            
            
            let note = WallNote(frame: CGRectMake(0,0,dim,dim), noteType:noteType, noteText: noteText, noteFont:noteTextFont, noteFontSize:noteTextFontSize, noteFontColor:Common.sharedCommon.formColorWithRGB(noteTextColor), isNote:noteProperty, imageFileName: imageName, isPinned:isPinned)
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
        
        if (noteOwnerLabel != nil) {
            
            noteOwnerLabel!.removeFromSuperview()
            noteOwnerLabel = nil
            
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
                self.noteOwnerLabel!.removeFromSuperview()
                self.favButton = nil
                self.followButton = nil
                self.noteOwnerLabel = nil
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
        
        transImage!.image = nil
        transImage!.image = UIImage(named: self.backgroundImageName!)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
               self.masterView!.center = CGPointMake(self.masterView!.center.x + UIScreen.mainScreen().bounds.size.width, self.masterView!.center.y)
            
            }) { (Bool) -> Void in
                
                self.backgroundImage!.removeFromSuperview()
                self.backgroundImage = nil
                self.masterView!.removeFromSuperview()
                self.masterView = nil
                self.wallTypeNotifyImage!.removeFromSuperview()
                self.wallTypeNotifyImage = nil
                self.loadMainView(resetDataSource:true)
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
                self.fillInDataSource(false,ignoreCache:false)
                
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
                self.fillInDataSource(false,ignoreCache:true)
                
                for v in self.masterView!.subviews {
                    
                    if v is WallNote {
                        
                        if (v as? WallNote)!.ownerID == followOwner {
                            
                            (v as? WallNote)!.followingNoteOwner = note.followingNoteOwner
                            
                        }
                    }
                }
                
            }
        }
        
        
    }
    
    
    func removeOptionsViews() {
        
        if (self.profileView != nil) {
            
            self.profileView!.removeFromSuperview()
            self.profileView = nil
        }
    }
    
    
    func showOptionsMenu() {
        
        self.animateView(nil)
        
        if (subOptions != nil) {
            
            self.showSubOptionsMenu()
        }
        
        if (options == nil) {
            
            self.masterView!.userInteractionEnabled = false
            //transImage!.image = UIImage(named: self.backgroundImageName!)
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
            
            let optionsHeight = Common.sharedCommon.calculateDimensionForDevice(40)
            options = OptionsView(frame:CGRectMake(0,-optionsHeight,UIScreen.mainScreen().bounds.size.width,optionsHeight), options:kMenuOptions)
            options!.delegate = self
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    self.masterView!.alpha = 0.0
                    
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
            
            
            self.masterView!.userInteractionEnabled = true
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    self.masterView!.alpha = 1.0
                    
                    var newFrame = self.options!.frame
                    newFrame.origin.y = -newFrame.size.height
                    self.options!.frame = newFrame
                    
                    self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.center.y - newFrame.size.height)
                    
                    }, completion: { (Bool) -> Void in
                        self.options?.removeFromSuperview()
                        self.options = nil
                        self.transImage!.image = nil
                })
                
            })

        }
        
    }
    
    
    func showSubOptionsMenu() {
        
        self.animateView(nil)
        
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
            
            self.removeOptionsViews()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
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
