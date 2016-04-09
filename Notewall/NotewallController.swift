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

class NotewallController:UIViewController, UIScrollViewDelegate, WallNoteDelegate, NoteDelegate,UITextViewDelegate,ComposeDelegate, CloseViewProtocolDelegate, ConfirmProtocolDelegate,OptionsViewProtocolDelegate, OptionsOptionViewProtocolDelegate,CacheManagerProtocolDelegate,SettingsControllerProtocolDelegate {
    
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
    var notesDataList:Array<WallNote> = []
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
    var optionsOptionView:OptionsOptionView?
    var aboutView:AboutView?
    var filledInOptionsView:UIView? = nil
    var activity:UIActivityIndicatorView? = nil
    var refreshImage:UIImageView?
    var hamburgerImage:UIImageView?
    var hamburgerTableView:OptionsOptionView?
    var settingsController:SettingsController?
    var profileController:ProfileController?
    var followersController:FollowersController?
    var paymentController:PaymentController?
    var timer:NSTimer?
    
    var screenWidth:CGFloat = UIScreen.mainScreen().bounds.size.width
    var screenHeight:CGFloat = UIScreen.mainScreen().bounds.size.height

    
    override func viewDidLoad() {
        
        CacheManager.sharedCacheManager.cacheDelegate = self
        
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
    
   override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        Common.sharedCommon.invalidateTimerAndRemoveMessage()
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
            
            let bgImageSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NotewallController.changeNoteWall(_:)))
            bgImageSwipe.direction = .Right
            backgroundImage!.addGestureRecognizer(bgImageSwipe)
            
            let bgImageSwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(NotewallController.changeNoteWall(_:)))
            bgImageSwipeLeft.direction = .Left
            backgroundImage!.addGestureRecognizer(bgImageSwipeLeft)
            
            
           /* let singleTap = UITapGestureRecognizer(target: self, action: "changeNoteWall:")
            singleTap.numberOfTapsRequired = 1
            backgroundImage!.addGestureRecognizer(singleTap)*/
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(NotewallController.switchToCompose(_:)))
            //doubleTap.numberOfTapsRequired = 2
            doubleTap.numberOfTapsRequired = 1
            backgroundImage!.addGestureRecognizer(doubleTap)
            
            //singleTap.requireGestureRecognizerToFail(doubleTap)
            
            
            let wallTypeDim = Common.sharedCommon.calculateDimensionForDevice(35)
            wallTypeNotifyImage = UIImageView(frame: CGRectMake(0,0,wallTypeDim,wallTypeDim))
            wallTypeNotifyImage!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, wallTypeDim * 0.5)
            wallTypeNotifyImage!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
            wallTypeNotifyImage!.image = UIImage(named: self.wallTypeNotifyImageName!)
            wallTypeNotifyImage!.userInteractionEnabled = true
            self.view.addSubview(wallTypeNotifyImage!)
            let notifyTap = UITapGestureRecognizer(target: self, action: #selector(NotewallController.showOptionsMenu))
            wallTypeNotifyImage!.addGestureRecognizer(notifyTap)
            
            
            self.refreshImage = UIImageView(frame: CGRectMake(0,0,wallTypeDim,wallTypeDim))
            self.refreshImage!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width - self.refreshImage!.frame.size.width * 0.5 , wallTypeDim * 0.5)
            self.refreshImage!.image = UIImage(named: "refresh.png")
            self.refreshImage!.userInteractionEnabled = true
            self.refreshImage!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
            self.view.addSubview(self.refreshImage!)
            let refreshTap = UITapGestureRecognizer(target: self, action: #selector(NotewallController.refreshTapped))
            self.refreshImage!.addGestureRecognizer(refreshTap)
            self.refreshImage!.alpha = 0.0
            self.refreshImage!.userInteractionEnabled = false
            
            if (self.dataSourceAPI == kAllowedPaths.kPathGetAllNotes) {
                
                self.refreshImage!.alpha = 1.0
                self.refreshImage!.userInteractionEnabled = true
            }
            
            
            self.hamburgerImage = UIImageView(frame: CGRectMake(0,0,wallTypeDim,wallTypeDim))
            self.hamburgerImage!.center = CGPointMake(self.hamburgerImage!.frame.size.width * 0.5 , wallTypeDim * 0.5)
            self.hamburgerImage!.image = UIImage(named: "hamburger.png")
            self.hamburgerImage!.userInteractionEnabled = true
            self.hamburgerImage!.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
            self.view.addSubview(self.hamburgerImage!)
            self.hamburgerImage!.alpha = 0.0
            let hamburgerTap = UITapGestureRecognizer(target: self, action: #selector(NotewallController.showHamburgerOptions))
            self.hamburgerImage!.addGestureRecognizer(hamburgerTap)
            
            if (self.dataSourceAPI == kAllowedPaths.kPathNil) {
                
                self.hamburgerImage!.alpha = 1.0
                self.hamburgerImage!.userInteractionEnabled = true
            }
            
            
        }
        
        if (activity == nil) {
            
            activity = UIActivityIndicatorView(frame: CGRectMake(0,0,30,30))
            activity!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.10)
            
        }
        self.masterView!.addSubview(activity!)
        
        if (CacheManager.sharedCacheManager.allNotes.count == 0 ) {
            
            self.fillInDataSource(true,ignoreCache:true,overrideDatasourceAPIWith:nil)
            
        }
        else if (resetDataSource == true) {
            
            
            self.fillInDataSource(true,ignoreCache:false,overrideDatasourceAPIWith:nil)
            
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
    
    
    func fillInDataSource(refreshUI:Bool,ignoreCache:Bool,overrideDatasourceAPIWith:kAllowedPaths?) {
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        if (ignoreCache == true) {
            
                self.activityStartAnimating()
                var finalDatasourceAPI = self.dataSourceAPI!
                if (overrideDatasourceAPIWith != nil) {
                
                    finalDatasourceAPI = overrideDatasourceAPIWith!
                }
            
                Common.sharedCommon.postRequestAndHadleResponse(finalDatasourceAPI, body: data, replace: nil,requestContentType:kContentTypes.kApplicationJson) { (result, response) -> Void in
                
                        self.activityStopAnimating()
                
                        if (result == true) {
                    
                                if (response["data"]!["error"] != nil) {
                                    
                                        let errMessage = response["data"]!["error"] as! String
                                        if errMessage.rangeOfString("Denied") != nil {
                                        
                                                self.noteWallDelegate!.handleLogout()
                                        }
                                        else {
                                            
                                            Common.sharedCommon.showMessageViewWithMessage(self.view, message: response["data"]!["error"] as! String,startTimer:false)
                                        }
                        
                                }
                                else {
                    
                        
                                        let respData = response.objectForKey("data")
                                        //self.notesDataList = respData! as! Array<Dictionary<String, AnyObject>>
                                    
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        
                                        self.notesDataList.removeAll()
                                        self.formNoteFromData(respData! as! Array<Dictionary<String, AnyObject>>,api:finalDatasourceAPI,refreshUI:refreshUI)
                                        
                                        if (self.dataSourceAPI! == kAllowedPaths.kPathGetAllNotes) {
                                            
                                            //CacheManager.sharedCacheManager.allNotesDataList = respData! as! Array<Dictionary<String, AnyObject>>
                                            //CacheManager.sharedCacheManager.filterResults()
                                        }
                                        
                                    })
                        
                                       /* if (self.dataSourceAPI! == kAllowedPaths.kPathGetAllNotes) {
                            
                                                CacheManager.sharedCacheManager.allNotesDataList = respData! as! Array<Dictionary<String, AnyObject>>
                                                CacheManager.sharedCacheManager.filterResults()
                                        }
                                        if (refreshUI == true) {
                            
                                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                                        self.showExistingNotes()
                                                })
                                        } */
                                }
                    
                      }
                      else {
                    
                                Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Network Error",startTimer:false)
                                print(response)
                      }
               }
            
        }
        else {
                
               /* switch self.dataSourceAPI! {
                    
                case kAllowedPaths.kPathGetAllNotes:
                    self.notesDataList = CacheManager.sharedCacheManager.allNotesDataList
                case kAllowedPaths.kPathGetNotesForOwner:
                    self.notesDataList = CacheManager.sharedCacheManager.myNotesDataList
                case kAllowedPaths.kPathGetFavNotesForOwner:
                    self.notesDataList = CacheManager.sharedCacheManager.myFavsNotesDataList
                default:
                    break
                    
                } */
            
            switch self.dataSourceAPI! {
                
            case kAllowedPaths.kPathGetAllNotes:
                self.notesDataList = CacheManager.sharedCacheManager.allNotes
            case kAllowedPaths.kPathGetNotesForOwner:
                self.notesDataList = CacheManager.sharedCacheManager.myNotes
            case kAllowedPaths.kPathGetFavNotesForOwner:
                self.notesDataList = CacheManager.sharedCacheManager.favNotes
            default:
                self.notesDataList = []
                break
                
            }
            
                if (refreshUI == true) {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.showExistingNotes()
                    })
                    
                }
            }
    }
    
    
    func formNoteFromData(var data:Array<Dictionary<String, AnyObject>>,api:kAllowedPaths,refreshUI:Bool) {
        
        CacheManager.sharedCacheManager.clearCache()
        
        while (data.count > 0 ){
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(kNoteDim)
            
            let note = WallNote(frame: CGRectMake(0,0,dim,dim),data:data[0])
            self.notesDataList.append(note)
            
            if (refreshUI == true) {
                
                //self.showExistingNotes()
                self.addNoteToFav(note)
            }
            
            
            if (api == kAllowedPaths.kPathGetAllNotes) {
                
                CacheManager.sharedCacheManager.allNotes.append(note)
            }
            
            data.removeFirst()
        }
        
        CacheManager.sharedCacheManager.filterResults()
    }
    
    
    
    func addNoteToFav(note:WallNote) {
            
        let dim = Common.sharedCommon.calculateDimensionForDevice(kNoteDim)
            
        note.center = note.pinPoint!
        note.wallnoteDelegate = self
        note.center = note.pinPoint!
            
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                UIView.animateWithDuration(0.0, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    
                    
                    note.frame = CGRectMake(note.frame.origin.x, note.frame.origin.y, 0, 0)
                   
                    
                    }, completion: { (Bool) -> Void in
                        
                        self.masterView!.addSubview(note)
                        
                        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                            
                            note.frame = CGRectMake(note.frame.origin.x, note.frame.origin.y, dim, dim)
                            
                            }, completion: { (Bool) -> Void in
                                
                                
                        })
                })
        }
    }
    
    // CACHEMANAGER DELEGATE METHODS
    
    func requestToRunAPIDataSource() {
        
        self.fillInDataSource(false, ignoreCache: true, overrideDatasourceAPIWith: kAllowedPaths.kPathGetAllNotes)
    }

    
    //SCROLLVIEW DELEGATE METHODS
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return self.masterView!
        
    }
    
    // WALLNOTE DELEGATE METHODS
    
    func blowupWallNote(note: WallNote) {
        
        self.backgroundImage?.userInteractionEnabled = false
        
        if (favButton == nil) {
            
            let favButtonDim = Common.sharedCommon.calculateDimensionForDevice(50)
            favButton = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - favButtonDim - 10, favButtonDim, favButtonDim, favButtonDim))
            favButton!.userInteractionEnabled = true
            self.view.addSubview(favButton!)
            favButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(NotewallController.favButtonTapped))
            favButton!.addGestureRecognizer(tap)
        }
        
        if (followButton == nil) {
            
            let followButtonDim = Common.sharedCommon.calculateDimensionForDevice(50)
            followButton = UIImageView(frame: CGRectMake(10, followButtonDim, followButtonDim, followButtonDim))
            followButton!.userInteractionEnabled = true
            self.view.addSubview(followButton!)
            followButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(NotewallController.followButtonTapped))
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
        v.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleBottomMargin).union(.FlexibleTopMargin)
        v.noteDelegate = self
        //v.sourceWallNote = note
        self.view.addSubview(v)
        
        var pinYOffset:CGFloat = 0
        
        if (note.isNote == true) {
            
            pinYOffset = Common.sharedCommon.calculateDimensionForDevice(17)
        }
        
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            if (self.blownUpCount == 0) {
                
                self.blownUpCenterX = UIScreen.mainScreen().bounds.size.width * 0.5
                
            }
            else if (self.blownUpCount >= 1) {
                
                    self.blownUpCenterX = self.blownUpCenterX + self.blowUpXOffset
            }
            
                v.frame = CGRectMake(0, 0, Common.sharedCommon.calculateDimensionForDevice(kBlownupNoteDim), Common.sharedCommon.calculateDimensionForDevice(kBlownupNoteDim))
                v.pinImage?.center = CGPointMake(v.frame.size.width * 0.5,v.pinImage!.center.y + pinYOffset)
                let center = CGPointMake(self.blownUpCenterX, UIScreen.mainScreen().bounds.size.height * 0.60)
                v.center = center
                //self.bgScrollView!.zoomToRect(self.view.frame, animated: true)
            
                if (v.polaroid != nil) {
                
                    let polRect = CGRectInset(v.bounds,10,10)
                    v.polaroid!.frame = polRect
                
                }
            
            
                self.masterView!.alpha = 0.6
            
            
            }) { (Bool) -> Void in
                
                self.blownUpCount = self.blownUpCount + 1
                self.allBlownUpNotes.append(note)
                
        }
    }
    
    
    func wallNoteMovedToPoint(note: WallNote, point: CGPoint) {
        
        note.pinPoint = point
        let index = CacheManager.sharedCacheManager.allNotes.indexOf({$0.stickyNoteID == note.stickyNoteID!})
        let tempNote = CacheManager.sharedCacheManager.allNotes[index!]
        tempNote.pinPoint = CGPointMake(point.x, point.y)
        CacheManager.sharedCacheManager.allNotes[index!] = tempNote
    }
    
    // CONFIRM DELEGATE METHODS
    
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
        
                                CacheManager.sharedCacheManager.removeNoteFromCache(note!.sourceWallNote!)
                                note!.sourceWallNote!.removeAttributes(note!.sourceWallNote!)
                                self.blowUpRemovalCommonActions(note!)
                                self.fillInDataSource(false,ignoreCache:true,overrideDatasourceAPIWith:kAllowedPaths.kPathGetAllNotes)
        
                        }
                })
            }
        })
    }
    
    func cancelTapped(sender: ConfirmView, requester:AnyObject?) {
        
        (requester as? Note)!.alpha = 1.0
        self.favButton?.alpha = 1.0
        self.followButton?.alpha = 1.0
        self.noteOwnerLabel?.alpha = 1.0
        
    }
    
    
    //NOTE DELEGATE METHODS
    
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
        
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        
        if note.sourceWallNote!.isPinned == true && ownerID != note.sourceWallNote!.ownerID! {
            
            Common.sharedCommon.showMessageViewWithMessage(self.view, message: "Pinned Note cannot be deleted", startTimer: true)
            note.alpha = 1.0
        }
        else {
            
            let confirm = ConfirmView(frame: CGRectMake(0,0,380,200),requester:note)
            confirm.confirmDelegate = self
            confirm.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, -confirm.frame.size.height)
            self.view.addSubview(confirm)
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                    
                    
                    confirm.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.5)
                    self.favButton!.alpha = 0.0
                    self.followButton!.alpha = 0.0
                    self.noteOwnerLabel!.alpha = 0.0
                    
                    }, completion: { (Bool) -> Void in
                        
                })
            }

        }
        
        
    }
    
    // COMPOSE DELEGATE METHODS
    
    func postAWallNote(noteType: String?, noteText: String?, noteFont: String?, noteFontSize:CGFloat?, noteFontColor:Array<CGFloat>, noteProperty:String?, imageurl:String?, isPinned:Bool, pinType:String?) {
        
        let ownerID = Common.sharedCommon.config!["ownerId"] as! String
        let point = Common.sharedCommon.getACoordinate(screenWidth, screenheight: screenHeight)
        let xPoint = point.x
        let yPoint = point.y
        var contentType = kContentTypes.kApplicationJson
        //var isNote = true
        var data = [String:AnyObject]()
        data = ["ownerid" : ownerID as String, "notetype" : noteType! as String, "notetext" : noteText! as String, "notetextfont" : noteFont! as String, "notetextfontsize" : noteFontSize! as CGFloat, "notepinned": isPinned, "pintype":pinType!, "notetextcolor" : noteFontColor,"noteProperty" : noteProperty!, "imageurl" : imageurl!,"pinPoint":[xPoint,yPoint]]
        
        if (noteProperty == "P") {
            
           contentType = kContentTypes.kMultipartFormData
            //isNote = false
        }
        
       Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathPostNewNote, body: data, replace: nil, requestContentType:contentType) { (result, response) -> Void in
            
            if (result == true) {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let data = response["data"]! as! Array<Dictionary<String,AnyObject>>
                    let newNote = data[0]
                    let note = WallNote(frame: CGRectMake(100, 30, Common.sharedCommon.calculateDimensionForDevice(kNoteDim),Common.sharedCommon.calculateDimensionForDevice(kNoteDim)), data: newNote)
                    note.wallnoteDelegate = self
                    self.masterView!.addSubview(note)
                    
                    self.fillInDataSource(false,ignoreCache:true,overrideDatasourceAPIWith:kAllowedPaths.kPathGetAllNotes)
                    CacheManager.sharedCacheManager.allNotes.append(note)
                    CacheManager.sharedCacheManager.filterResults()

                    
                })
            }
            else {
                
                print(response)
            }
            
            
        }
    }
    
    // CLOSEVIEW DELEGATE METHODS
    
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
        //self.showSubOptionsMenu()
    }
    
    func optionItemProfile() {
        
      /*  if (profileView != filledInOptionsView) {
            
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
            
        } */
        
    }
    
    func optionItemOptions() {
        
        if (optionsOptionView != filledInOptionsView) {
            
            optionsOptionView = nil
        }
        
        self.optionsOptionView?.removeFromSuperview()
        self.optionsOptionView = nil
        
        if (optionsOptionView == nil) {
            
            //let yPos = self.wallTypeNotifyImage!.frame.origin.y + self.wallTypeNotifyImage!.frame.size.height
            //optionsOptionView = OptionsOptionView(frame: CGRectMake(0,-UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos))
            
            optionsOptionView = OptionsOptionView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height),fromSettings:true)
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
    
    
    // OPTIONSOPTIONS DELEGATE METHOD
    
    func followingUpdated(followingID: String) {
        
        self.fillInDataSource(false, ignoreCache: true,overrideDatasourceAPIWith:nil)
        
        for v in self.masterView!.subviews {
            
            if v is WallNote {
                
                if ((v as? WallNote)!.ownerID == followingID) {
                    
                    (v as? WallNote)!.followingNoteOwner = false
                }
            }
        }
        
        var index = 0
        for cachedNote in CacheManager.sharedCacheManager.allNotesDataList {
            
            if cachedNote["ownerID"] as! String == followingID {
                
                CacheManager.sharedCacheManager.allNotesDataList[index]["followingNoteOwner"] = false
            }
            
            index = index + 1
        }

    }
    
    
    func showNotesForSelectedFollowingOwnerInWall(dataList:NSArray) {
        
        self.notesDataList = dataList as! Array<WallNote>
        
        if (self.settingsController != nil) {
            
            self.removeSettingOptionsController()
            self.showOptionsMenu()
        }
        
        
       if (self.dataSourceAPI == kAllowedPaths.kPathNil) {
        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
                if (self.hamburgerTableView  != nil) {
                
                    self.showHamburgerOptions()
                }
            
                self.removeExistingNotes()
                self.showExistingNotes()
            })
        }
        else {
            
            self.backgroundImageIndex = 3
            let lSwipe = UISwipeGestureRecognizer()
            lSwipe.direction = .Right
            self.postNotesInMovedWall(lSwipe, resetDataSource: false)
        
        
        }
    }
    
    
    func overrideChangeWall(data:NSArray) {
        
       self.notesDataList = data as! Array<WallNote>
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if (self.hamburgerTableView  != nil) {
                
                self.showHamburgerOptions()
            }
            
            self.removeExistingNotes()
            self.showExistingNotes()
        })
    }
    
    
    // SETTINGSCONTROLLER DELEGATE METHODS
    
    func handleSettingsSelector(sel: String) {
        
        self.removeSettingOptionsController()
        
        let selector = Selector(sel)
        self.performSelector(selector)
    }
    
    
    // CUSTOM METHODS
    
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
        
        if (self.notesDataList.count > 0 ) {
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(kNoteDim)
            let note = self.notesDataList[0]
            
            note.center = note.pinPoint!
            note.wallnoteDelegate = self
            self.masterView!.addSubview(note)
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                UIView.animateWithDuration(0.00001, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    
                    
                    note.frame = CGRectMake(note.frame.origin.x, note.frame.origin.y, dim, dim)
                    note.center = note.pinPoint!
                    
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
    }
    
    func showNoNotes() {
        
        if (messageView == nil && self.dataSourceAPI != kAllowedPaths.kPathNil) {
            
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
        
        if (sender.numberOfTapsRequired == 1 && (self.dataSourceAPI != kAllowedPaths.kPathGetFavNotesForOwner && self.dataSourceAPI != kAllowedPaths.kPathNil)) {
            
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
                self.backgroundImage?.userInteractionEnabled = true
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
                
            })
        }
        
    }
    
    func changeNoteWall(sender:AnyObject) {
        
        self.removeExistingNotes()
        
        if (sender is UISwipeGestureRecognizer) {
            
             self.moveWall(sender as! UISwipeGestureRecognizer)
        }
    }
    
    func moveWall(sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == UISwipeGestureRecognizerDirection.Left) {
            
            self.backgroundImageIndex = self.backgroundImageIndex - 1
        }
        else {
            
            self.backgroundImageIndex = self.backgroundImageIndex + 1
            
        }
        
        
        if (self.backgroundImageIndex >= kBackGrounds.count) {
            
            self.backgroundImageIndex = 0
        }
        else if (self.backgroundImageIndex < 0 ) {
            
            self.backgroundImageIndex = kBackGrounds.count - 1
        }
        
        self.postNotesInMovedWall(sender,resetDataSource:true)
        
    }
    
    func postNotesInMovedWall(sender:UISwipeGestureRecognizer,resetDataSource:Bool) {
        
        self.backgroundImageName = kBackGrounds[self.backgroundImageIndex]["bg"] as? String
        self.dataSourceAPI = kBackGrounds[self.backgroundImageIndex]["datasource"] as? kAllowedPaths
        self.wallTypeNotifyImageName = kBackGrounds[self.backgroundImageIndex]["icon"] as? String
        self.wallTypeNotifyImage!.userInteractionEnabled = true
        
        transImage!.image = nil
        transImage!.image = UIImage(named: self.backgroundImageName!)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            if (sender.direction == UISwipeGestureRecognizerDirection.Left) {
                
                self.masterView!.center = CGPointMake(self.masterView!.center.x - UIScreen.mainScreen().bounds.size.width, self.masterView!.center.y)
            }
            else {
                
                self.masterView!.center = CGPointMake(self.masterView!.center.x + UIScreen.mainScreen().bounds.size.width, self.masterView!.center.y)
            }
            
        }) { (Bool) -> Void in
            
            self.backgroundImage!.removeFromSuperview()
            self.backgroundImage = nil
            self.masterView!.removeFromSuperview()
            self.masterView = nil
            self.wallTypeNotifyImage!.removeFromSuperview()
            self.wallTypeNotifyImage = nil
            self.activity?.removeFromSuperview()
            self.activity = nil
            self.refreshImage!.removeFromSuperview()
            self.refreshImage = nil
            self.hamburgerImage!.removeFromSuperview()
            self.hamburgerImage = nil
            self.hamburgerTableView?.removeFromSuperview()
            self.hamburgerTableView = nil
            self.loadMainView(resetDataSource:resetDataSource)
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
                CacheManager.sharedCacheManager.replaceWallNote(note, key: "favedOwners", value: note.favedOwners!)
                self.fillInDataSource(false,ignoreCache:true,overrideDatasourceAPIWith:kAllowedPaths.kPathGetAllNotes)
                
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
                
                for v in self.masterView!.subviews {
                    
                    if v is WallNote {
                        
                        if (v as? WallNote)!.ownerID == followOwner {
                            
                            (v as? WallNote)!.followingNoteOwner = note.followingNoteOwner
                            //let index =  CacheManager.sharedCacheManager.allNotes.indexOf((v as? WallNote)!)
                            //let temp = CacheManager.sharedCacheManager.allNotes[index!]
                            //temp.followingNoteOwner = note.followingNoteOwner
                            //CacheManager.sharedCacheManager.allNotes[index!] = temp
                            
                        }
                    }
                }
                
                var index = 0
                for cachedNote in CacheManager.sharedCacheManager.allNotes {
                    
                    if cachedNote.ownerID == followOwner {
                        
                        CacheManager.sharedCacheManager.allNotes[index].followingNoteOwner = note.followingNoteOwner
                    }
                    
                    index = index + 1
                }
                
               self.fillInDataSource(false,ignoreCache:true,overrideDatasourceAPIWith:nil)
            }
        }
        
    }
    
    
    func showOptionsMenu() {
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        if (self.settingsController == nil) {
            
            self.masterView!.userInteractionEnabled = false
            self.settingsController = SettingsController()
            self.settingsController!.settingsDelegate = self
            
            self.addChildViewController(settingsController!)
            self.view.addSubview(self.settingsController!.view)
            self.settingsController!.didMoveToParentViewController(self)
            
            self.settingsController!.view.center = CGPointMake(self.settingsController!.view.center.x, -self.settingsController!.view.center.y)
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: {
                
                self.masterView!.alpha = 0.0
                self.settingsController!.view.center = CGPointMake(self.settingsController!.view.center.x, self.settingsController!.view.frame.size.height * 0.5)
                self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.center.y + self.settingsController!.view.frame.size.height)
                
                }) { (Bool) in
                
            }
        }
        else {
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: {
                
                self.removeSettingOptionsController()
                
                self.masterView!.alpha = 1.0
                self.settingsController!.view.center = CGPointMake(self.settingsController!.view.center.x, -self.settingsController!.view.frame.size.height)
                self.wallTypeNotifyImage!.center = CGPointMake(self.wallTypeNotifyImage!.center.x, self.wallTypeNotifyImage!.frame.size.height * 0.5)
                
                }) { (Bool) in
                    
                
                    self.settingsController!.view.removeFromSuperview()
                    self.settingsController!.removeFromParentViewController()
                    self.settingsController = nil
                    
                    self.masterView!.userInteractionEnabled = true
            }
            
        }
        
        
        
        
       /* self.animateView(nil)
        
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

        } */
        
    }
    
    
    func showSubOptionsMenu() {
        
       /* self.animateView(nil)
        
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
            
        } */
        
    }
    
    
    
    func showHamburgerOptions() {
        
       if (self.hamburgerTableView  == nil) {
        
            self.hamburgerTableView  = OptionsOptionView(frame: CGRectMake(-UIScreen.mainScreen().bounds.size.width,self.hamburgerImage!.frame.size.height, UIScreen.mainScreen().bounds.size.width,300),fromSettings:false)
            self.hamburgerTableView!.optionsOptionsDelegate = self
            self.view.addSubview(self.hamburgerTableView!)
        
            dispatch_async(dispatch_get_main_queue(), { 
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { 
                    
                    self.masterView!.alpha = 0.3
                    //self.refreshImage!.alpha = 0.0
                    self.wallTypeNotifyImage!.userInteractionEnabled = false
                    
                    self.hamburgerTableView!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5,self.hamburgerTableView!.center.y)
                    
                    }, completion: { (Bool) in
                        
                })
                
                
            })
        }
       else {
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: {
                
                self.masterView!.alpha = 1.0
                //self.refreshImage!.alpha = 1.0
                
                self.hamburgerTableView!.center = CGPointMake(-UIScreen.mainScreen().bounds.size.width,self.hamburgerTableView!.center.y)
                
                    }, completion: { (Bool) in
                    
                        self.hamburgerTableView!.removeFromSuperview()
                        self.hamburgerTableView = nil
                         self.wallTypeNotifyImage!.userInteractionEnabled = true
                })
            
            
            })
        
        }

    }
    
    
    func refreshTapped() {
        
        //self.refreshImage!.transform = CGAffineTransformMakeRotation(0.34906585);
        self.removeExistingNotes()
        self.fillInDataSource(true, ignoreCache: true, overrideDatasourceAPIWith: kAllowedPaths.kPathGetAllNotes)
    }
    
    
    func removeSettingOptionsController() {
        
        if (self.profileController != nil) {
            
            self.profileController!.view.removeFromSuperview()
            self.profileController!.removeFromParentViewController()
            self.profileController = nil
        }
        
        
        if (self.followersController != nil) {
            
            self.followersController!.view.removeFromSuperview()
            self.followersController!.removeFromParentViewController()
            self.followersController = nil
        }
        
        if (self.paymentController != nil) {
            
            self.paymentController!.view.removeFromSuperview()
            self.paymentController!.removeFromParentViewController()
            self.paymentController = nil
        }
        
        
    }
    
    
    func profileTapped() {
        
        if (self.profileController == nil) {
            
            let yPos = self.settingsController!.view.frame.size.height
            let frame = CGRectMake(0,yPos,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos)
            self.profileController = ProfileController(frame:frame)
            self.addGivenController(self.profileController!)
        }
    }
    
    
    func followersTapped() {
        
        if (self.followersController == nil) {
            
            let yPos = self.settingsController!.view.frame.size.height
            let frame = CGRectMake(0,yPos,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos)
            self.followersController  = FollowersController(frame:frame)
            self.addGivenController(self.followersController!)
        }
    }
    
    
    func pinTapped() {
        
        if (self.paymentController == nil) {
            
            let yPos = self.settingsController!.view.frame.size.height
            let frame = CGRectMake(0,yPos,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos)
            self.paymentController  = PaymentController(frame:frame, overrideTextColor:nil)
            self.addGivenController(self.paymentController!)
        }
    }
    
    
    func addGivenController(viewcontroller:UIViewController) {
        
        self.addChildViewController(viewcontroller)
        self.view.addSubview(viewcontroller.view)
        viewcontroller.didMoveToParentViewController(self)
        
        self.view.insertSubview(viewcontroller.view, belowSubview:self.wallTypeNotifyImage!)
    }
    
    
    func logoutTapped() {
        
        self.removeSettingOptionsController()
        
        if (self.settingsController != nil) {
            
            
            self.settingsController!.view.removeFromSuperview()
            self.settingsController!.removeFromParentViewController()
            self.settingsController = nil
        }
        
        if (self.noteWallDelegate != nil) {
            
            self.noteWallDelegate!.handleLogout()
        }
    }

    
}
