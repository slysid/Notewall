//
//  ComposeNoteController.swift
//  Notewall
//
//  Created by Bharath on 24/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol ComposeDelegate {
    
    func postAWallNote(noteType:String?,noteText:String?,noteFont:String?,noteFontSize:CGFloat?,noteFontColor:Array<CGFloat>,noteProperty:String?,imageurl:String?,isPinned:Bool,pinType:String?)
}


class Compose:UIViewController,UITextViewDelegate,UIScrollViewDelegate,ComposeNoteDelegate,CloseViewProtocolDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,PinBuyProtocolDelegate,PinButtonProtocolDelegate {
    
    
    var newNoteView:UIView?
    var notesImageView:ComposeNote?
    var polaroidImageView:UIImageView?
    var noteTypesScroll:SettingsScroll?
    var noteFontsScroll:SettingsScroll?
    var noteFontSizeScroll:SettingsScroll?
    var noteFontColorScroll:SettingsScroll?
    var postButton:CustomButton?
    var textField:UITextView?
    var enteredText:String?
    var selectedNoteIndex:Int = 0
    var selectedNoteInNoteIndex:Int = 0
    var selectedFontIndex:Int = 0
    var selectedFontSizeIndex:Int = 15
    var selectedFontColorIndex:Int = 0
    var composeDelegate:ComposeDelegate?
    var orgNotePosition:CGRect?
    var orgNoteCenter:CGPoint?
    var centerOffset:CGFloat = 0.0
    
    var currentLine:Int = 1
    var runningLine:Int = 1
    var maxLineForNoteMovement:Int = 3
    var previousLine:Int = -1
    var maxLinesAllowed = 0
    var stickyNotes:Array<String> = []
    var noteAdjustment:CGFloat = 40.0
    var noteDefaultYPos:CGFloat?
    var composeType:kComposeTypes = kComposeTypes.kComposeNote
    var composeNoteType:kComposeNoteTypes = kComposeNoteTypes.kNoteTypeFree
    var composeTypeImageView:UIImageView?
    var noteTypeImageView:UIImageView?
    var imgPicker:UIImagePickerController = UIImagePickerController()
    
    var pinchScale:CGFloat = 0.0
    var textFontSize:CGFloat = 30.0
    
    var pinBuyView:PinBuy?
    var paymentController:PaymentController?
    var noteBuyController:NoteBuyController?
    var activity:UIActivityIndicatorView?
    var pinPostView:UIView?
    var redSlider:UISlider?
    var blueSlider:UISlider?
    var greenSlider:UISlider?
    
    var noteLock:UIImageView?
    var postNote:UIImageView?
    var pinNote:UIImageView?
    
    override func viewDidLoad() {
        
        for noteTypes in kPinNotes {
            
            stickyNotes.append(noteTypes[0])
        }
        
        self.addNewNoteView(composeType)
        
        currentLine = maxLineForNoteMovement - 1
        
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        
        let dim = Common.sharedCommon.calculateDimensionForDevice(30)
        activity = UIActivityIndicatorView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width * 0.5,dim * 1.5,dim,dim))
        self.view.addSubview(activity!)
        
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        Common.sharedCommon.config![kKeyPolaroid] = nil
    }
    
    override func shouldAutorotate() -> Bool {
        
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
       /* if (self.composeType == kComposeTypes.kComposePicture) {
            
            return UIInterfaceOrientationMask.Portrait
        } */
        
        return UIInterfaceOrientationMask.All
    }
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if (self.notesImageView != nil)
        {
            if (UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait) {
                
                self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x, noteDefaultYPos!)
            }
            else {
                
               if (runningLine >= maxLineForNoteMovement && centerOffset == orgNoteCenter!.y) {
                    
                    moveNoteviewToMatch(true, offset: centerOffset - noteAdjustment)
                    
                }
                else {
                    
                    self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x, centerOffset)
                    
                }
                
            }
            
        }
        
    }
    
    
    //UIScrollView Delegate Methods
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
       /* if (scrollView == noteTypesScroll?.scrollView!) {
            
            let contentOffset:CGFloat = self.noteTypesScroll!.scrollView!.contentOffset.x
            selectedNoteIndex = Int(contentOffset / self.noteTypesScroll!.scrollView!.frame.size.width)
            //self.notesImageView!.image = UIImage(named: stickyNotes[selectedNoteIndex])
            self.notesImageView!.image = UIImage().noteImage(named: stickyNotes[selectedNoteIndex])
            
        } */
        
        if (scrollView == noteFontsScroll?.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontsScroll!.scrollView!.contentOffset.x
            selectedFontIndex = Int(contentOffset / self.noteFontsScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
        }
        
       /* if (scrollView == noteFontSizeScroll?.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontSizeScroll!.scrollView!.contentOffset.x
            selectedFontSizeIndex = Int(contentOffset / self.noteFontSizeScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
            
        }*/
        
        if (scrollView == noteFontColorScroll?.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontColorScroll!.scrollView!.contentOffset.x
            selectedFontColorIndex = Int(contentOffset / self.noteFontColorScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
        }
        
    }
    
    // Textview Delegate Methods
    
    func textViewDidChange(textView: UITextView) {
        
        self.enteredText = textView.text
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        runningLine = numLines
        self.checkForMovingview(numLines)
        
        
        
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if (runningLine <= maxLinesAllowed) {
            
            return true
        }
        else {
            
            if (text == "") {
                
                return true
            }
            
            return false
        }
    }
    
    // Compose Note Delegate Methods
    
    func composeDismissKeyboard() {
        
        self.dimissKeyboard()
    }
    
    func composeNoteSwipped() {
        
        self.noteSwiped()
    }
    
    // Close View Delegate Methods
    
    func handleCloseViewTap() {
        
        if (self.paymentController != nil ) {
            
            self.paymentController!.view.removeFromSuperview()
            self.paymentController!.removeFromParentViewController()
            self.paymentController = nil
            
        }
        else {
            
            if (textField != nil) {
                
                enteredText = textField!.text!
                textField!.resignFirstResponder()
                textField!.removeFromSuperview()
                textField = nil
            }
            
            if (notesImageView != nil) {
                
                notesImageView!.removeFromSuperview()
                notesImageView = nil
            }
            
            if (newNoteView != nil) {
                
                newNoteView!.removeFromSuperview()
                newNoteView = nil
            }
            
            self.dismissViewControllerAnimated(true) { () -> Void in
                
                
            }
            
        }

    }
    
    // ImagePicker Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
       /* let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        let imageName = imageURL.path!
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        let localPath = documentDirectory.stringByAppendingString(imageName)
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let data = UIImageJPEGRepresentation(image,1.0)
        data!.writeToFile(localPath, atomically: true)
        
        let imageData = NSData(contentsOfFile: localPath)!
        let photoURL = NSURL(fileURLWithPath: localPath)
        let imageWithData = UIImage(data: imageData)! */
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let data = UIImageJPEGRepresentation(image,1.0)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
           /* self.polaroidImageView!.image = imageWithData
            Common.sharedCommon.config!["polaroid"] = photoURL */
            
            self.polaroidImageView!.image = image
            Common.sharedCommon.config![kKeyPolaroid] = data
            
            
            /* UIGraphicsBeginImageContextWithOptions(CGSizeMake(kNoteDim,kNoteDim), false, 0.0);
            image.drawInRect(CGRectMake(0,0,kNoteDim,kNoteDim))
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            let thumbnailData = UIImageJPEGRepresentation(thumbnail,1.0)
            
            Common.sharedCommon.config![kKeyPolaroidThumbNail] = thumbnailData */
            
        }
        
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.polaroidImageView!.image = UIImage(named: "nophoto.png")
            Common.sharedCommon.config![kKeyPolaroid] = nil
        }
        
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
            
        }
    }
    
    
    // PINBUY DELEGATE METHODS
    
    func presentAlertController(action: UIAlertController) {
        
        self.presentViewController(action, animated: true) { () -> Void in
            
        }
    }
    
    func pinPurchaseSuccessful(result:Bool,message:String?) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            /*self.pinBuyView?.removeFromSuperview()
            self.pinBuyView = nil
            
            self.notesImageView?.alpha = 1.0
            self.polaroidImageView?.alpha = 1.0
            self.noteTypesScroll?.alpha = 1.0
            self.noteFontsScroll?.alpha = 1.0
            self.noteFontSizeScroll?.alpha = 1.0
            self.noteFontColorScroll?.alpha = 1.0 */
            
            
            if (result == true) {
                
                self.checkPinAvailability()
            }
            else {
                
                Common.sharedCommon.showMessageViewWithMessage(self.view, message: message!, startTimer: true)
            }
            
        }
        
    }
    
    // PinTypeBuyProtocolDelegate Methods
    
    func postAndDeductPinType(pintype: String) {
        
        let simulatePinTapGesture = UITapGestureRecognizer()
        let simulatedpinimage = UILabel()
        simulatedpinimage.text = pintype
        simulatedpinimage.tag = 2
        simulatedpinimage.addGestureRecognizer(simulatePinTapGesture)
        self.noteTapped(simulatePinTapGesture)
    }
    
    // Custom Methods
    
    func checkForMovingview(numlines:Int) {
        
        centerOffset = self.orgNoteCenter!.y
        var move:Bool = false
        
        if (runningLine != currentLine && runningLine >= maxLineForNoteMovement) {
            
            if (runningLine > previousLine) {
                
                centerOffset = self.notesImageView!.center.y - noteAdjustment
                move = true
                
            }
            else if (runningLine <= previousLine) {
               
                centerOffset = self.notesImageView!.center.y + noteAdjustment
                move = true
            }
            
            previousLine = currentLine
            currentLine = runningLine
            
        }
        else {
            
            previousLine = currentLine
            currentLine = runningLine
        }
        
        
        if (runningLine < maxLineForNoteMovement && self.notesImageView!.center.y != self.orgNoteCenter!.y) {
            
            previousLine = -1
            currentLine = maxLineForNoteMovement - 1
            centerOffset = self.orgNoteCenter!.y
            move = true
        }
        
        
        if (move == true && (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)) {
            
           /* UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x, centerOffset)
                
                }, completion: { (Bool) -> Void in
                    
                    
            }) */
            
            moveNoteviewToMatch(move, offset: centerOffset)
            move = false
            
        }
    }
    
    func moveNoteviewToMatch(decision:Bool,offset:CGFloat) {
        
        if (decision == true) {
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x, offset)
                
                }, completion: { (Bool) -> Void in
                    
                    
            })
            
        }
        
    }
    
    func dimissKeyboard() {
        
        if (self.textField!.isFirstResponder() == true) {
            
            self.textField!.resignFirstResponder()
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                    //self.notesImageView!.center = self.orgNoteCenter!
                      self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x,self.noteDefaultYPos!)
                
                }, completion: { (Bool) -> Void in
                    
                
            })
        }
        else {
            
            self.textField!.becomeFirstResponder()
            
            if (runningLine >= maxLineForNoteMovement && (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)) {
                
                let offset =  self.notesImageView!.center.y - (noteAdjustment * CGFloat(runningLine - maxLineForNoteMovement + 1))
                self.moveNoteviewToMatch(true, offset: offset)
            }
        }
    }
    
    func addNewNoteView(cType:kComposeTypes) {
        
        newNoteView = UIView(frame: self.view.frame)
        newNoteView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        
        let bgImage = UIImageView(frame: self.view.frame)
        bgImage.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth)
        bgImage.image = UIImage(named: kDefaultBGImageName)
        bgImage.userInteractionEnabled = true
        self.newNoteView!.addSubview(bgImage)
        self.view.addSubview(newNoteView!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(Compose.dimissKeyboard))
        bgImage.addGestureRecognizer(tap)
        
        
        let composeDim = Common.sharedCommon.calculateDimensionForDevice(35)
        
        if (self.composeTypeImageView == nil) {
            
            
            self.composeTypeImageView = UIImageView(frame: CGRectMake(0,0,composeDim,composeDim))
            self.composeTypeImageView!.userInteractionEnabled = true
            self.newNoteView!.addSubview(self.composeTypeImageView!)
            
            let composeTap = UITapGestureRecognizer(target: self, action: #selector(Compose.changeCompseMode))
            self.composeTypeImageView!.addGestureRecognizer(composeTap)
        }
        
        let noteTypeImageViewDim = Common.sharedCommon.calculateDimensionForDevice(35)
        
        if (self.noteTypeImageView == nil) {
            
            self.noteTypeImageView = UIImageView(frame: CGRectMake(self.composeTypeImageView!.frame.size.width + 5.0 ,0,noteTypeImageViewDim,noteTypeImageViewDim))
            self.noteTypeImageView!.userInteractionEnabled = true
            self.newNoteView!.addSubview(self.noteTypeImageView!)
            
            let composeTap = UITapGestureRecognizer(target: self, action: #selector(Compose.changeNoteTypeMode))
            self.noteTypeImageView!.addGestureRecognizer(composeTap)
        }
        
        //let buttonWidth = Common.sharedCommon.calculateDimensionForDevice(80)
        //let buttonHeight = Common.sharedCommon.calculateDimensionForDevice(35)
        
        
        //let xOffset = UIScreen.mainScreen().bounds.width * 0.5 - (buttonWidth * 0.5)
        //let yOffset = Common.sharedCommon.calculateDimensionForDevice(10)
        /*self.postButton = CustomButton(frame: CGRectMake(xOffset, yOffset, buttonWidth, buttonHeight), buttonTitle: kButtonPostText, normalColor: UIColor.redColor(), highlightColor: UIColor.blackColor())
        self.postButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleTopMargin).union(.FlexibleBottomMargin)
        self.postButton!.addTarget(self, action: "postTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.newNoteView!.addSubview(self.postButton!)*/
        
        let xOffset = UIScreen.mainScreen().bounds.width * 0.5 - (1.5 * composeDim)
        postNote  = UIImageView(frame: CGRectMake(xOffset, 0, composeDim, composeDim))
        postNote!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(.FlexibleBottomMargin)
        //postNote.image = UIImage(named: "noteBlue1.png")
        postNote!.image = UIImage().noteImage(named: kPinNotes[self.selectedNoteIndex][self.selectedNoteInNoteIndex])
        postNote!.userInteractionEnabled = true
        postNote!.tag = 1
        let postTap = UITapGestureRecognizer(target: self, action: #selector(Compose.noteTapped(_:)))
        postNote!.addGestureRecognizer(postTap)
        self.newNoteView!.addSubview(postNote!)
        
        
        pinNote  = UIImageView(frame: CGRectMake(xOffset + (1.5 * composeDim), 0, composeDim, composeDim))
        pinNote!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(.FlexibleBottomMargin)
        pinNote!.image = UIImage(named: "pin.png")
        pinNote!.userInteractionEnabled = true
        pinNote!.tag = 2
        let pinTap = UITapGestureRecognizer(target: self, action: #selector(Compose.checkPinAvailability))
        pinNote!.addGestureRecognizer(pinTap)
        self.newNoteView!.addSubview(pinNote!)
        
        
       /* let noteCategories = ["note1.png","note2.png"]
        let noteCategoryScrollUnitWidth:CGFloat = 30
        let noteCategoryScroll = UIScrollView(frame: CGRectMake(0,0,noteCategoryScrollUnitWidth * 2.0,noteCategoryScrollUnitWidth))
        noteCategoryScroll.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
        noteCategoryScroll.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5,pinNote.center.y + pinNote.frame.size.width)
        noteCategoryScroll.backgroundColor = UIColor.redColor()
        self.newNoteView!.addSubview(noteCategoryScroll) */
        
        
        
        let closeImage = CloseView(frame: CGRectMake(UIScreen.mainScreen().bounds.width - composeDim, 0, composeDim, composeDim))
        closeImage.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleBottomMargin)
        closeImage.closeViewDelegate = self
        self.view.addSubview(closeImage)
        
        if (cType == kComposeTypes.kComposeNote) {
            
            self.composeTypeImageView!.image = UIImage(named: "camera.png")
            
            if (self.composeNoteType == kComposeNoteTypes.kNoteTypeFree){
                
                self.noteTypeImageView!.image = UIImage(named:"snote.png")
            }
            else if (self.composeNoteType == kComposeNoteTypes.kNoteTypeSponsored){
                
                self.noteTypeImageView!.image = UIImage(named:"fnote.png")
                
            }
            
            self.composeNewNote()
        }
        else if (cType == kComposeTypes.kComposePicture){
            
            //let value = UIInterfaceOrientation.Portrait.rawValue
            //UIDevice.currentDevice().setValue(value, forKey: "orientation")
            self.composeTypeImageView!.image = UIImage(named: "notes.png")
            self.composeImageNote()
        }
        
        
        
    }
    
    
    func composeNoteChangeType(sender:UISwipeGestureRecognizer) {
        
        
        let dummyNoteView = UIImageView(frame:self.notesImageView!.frame)
        dummyNoteView.image = self.notesImageView!.image
        self.newNoteView!.addSubview(dummyNoteView)
        var currentCenter = dummyNoteView.center
        
        if (sender.direction == UISwipeGestureRecognizerDirection.Right) {
            
            selectedNoteIndex = selectedNoteIndex + 1
            
            /*if (selectedNoteIndex >= stickyNotes.count) {
                
                selectedNoteIndex = 0
            }*/
            
            if (selectedNoteIndex >= kPinNotes.count) {
                
                selectedNoteIndex = 0
            }
            
            currentCenter = CGPointMake(currentCenter.x + (dummyNoteView.frame.size.width * 1.5),currentCenter.y)

        }
        else if (sender.direction == UISwipeGestureRecognizerDirection.Left) {
            
            selectedNoteIndex = selectedNoteIndex - 1
            
            /* if (selectedNoteIndex < 0) {
                
                selectedNoteIndex = stickyNotes.count - 1
            }*/
            
            if (selectedNoteIndex < 0) {
                
                selectedNoteIndex = kPinNotes.count - 1
            }
            
            currentCenter = CGPointMake(currentCenter.x - (dummyNoteView.frame.size.width * 1.5),currentCenter.y)
        }
        
        
        dispatch_async(dispatch_get_main_queue(),{ () -> Void in
            
            
            //self.notesImageView!.image = UIImage(named: self.stickyNotes[self.selectedNoteIndex])
            //self.notesImageView!.image = UIImage(named: kPinNotes[self.selectedNoteIndex][self.selectedNoteInNoteIndex])
            
            if (self.selectedNoteInNoteIndex > kPinNotes[self.selectedNoteIndex].count - 1) {
                
                 self.selectedNoteInNoteIndex = 0
                
            }
                
            
            self.notesImageView!.image = UIImage().noteImage(named: kPinNotes[self.selectedNoteIndex][self.selectedNoteInNoteIndex])
            
            
             UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState , animations: { () -> Void in
                
                
                    dummyNoteView.center = currentCenter
                
                
                }, completion: { (Bool) -> Void in
                    
                    dummyNoteView.removeFromSuperview();
             })
            
        })
    }
    
    
    func handlePinch(sender:UIPinchGestureRecognizer) {
        
        self.textFontSize = self.textField!.font!.pointSize
        //let font = kSupportedFonts[selectedFontIndex]
        
        let scale = sender.scale
        
        if (scale > self.pinchScale) {
            
            if (self.textFontSize <= 60.0) {
                
                self.textFontSize = self.textFontSize + 1.0
            }
        }
        else {
            
            if (self.textFontSize > 20.0) {
                
                self.textFontSize = self.textFontSize - 1.0
            }
        }
        
        self.pinchScale = scale
        
        
        //self.textField!.font = UIFont(name: font, size: self.textFontSize);
        self.assignedTextAttributes()
    }
    
    
    
    func composeNewNote() {
        
        
       /* for font in kFontSizes {
            
            if (font == 30.0) {
                
                selectedFontSizeIndex = kFontSizes.indexOf(font)!
            }
        } */
        
        
        if (self.composeNoteType == kComposeNoteTypes.kNoteTypeFree || self.composeNoteType == kComposeNoteTypes.kNoteTypeSponsored ) {
            
            let width = Common.sharedCommon.calculateDimensionForDevice(290)
            noteDefaultYPos = Common.sharedCommon.calculateDimensionForDevice(30) + (width * 0.5)
            let noteFrame = CGRectMake(0,0,width,width * 0.90)
            
            
            notesImageView = ComposeNote(frame: noteFrame, withImage: kPinNotes[0][0], withFontSize:textFontSize)
            notesImageView!.center = CGPointMake(UIScreen.mainScreen().bounds.width * 0.5 , noteDefaultYPos!)
            notesImageView!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
            notesImageView!.composeNoteDelegate = self
            orgNotePosition = notesImageView!.frame
            orgNoteCenter = notesImageView!.center
            centerOffset = self.orgNoteCenter!.y
            textField = notesImageView!.composeTextView
            textField!.delegate = self
            self.newNoteView!.addSubview(notesImageView!)
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(Compose.composeNoteChangeType(_:)))
            rightSwipe.direction = .Right
            self.notesImageView!.addGestureRecognizer(rightSwipe)
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(Compose.composeNoteChangeType(_:)))
            leftSwipe.direction = .Left
            self.notesImageView!.addGestureRecognizer(leftSwipe)
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(Compose.handlePinch(_:)))
            self.notesImageView!.addGestureRecognizer(pinch)
            
            var xOffset:CGFloat = 5.0
            var yOffset:CGFloat = 0.0
            
            if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight) {
                
                yOffset = UIScreen.mainScreen().bounds.height * 0.15
            }
            else {
                
                yOffset = notesImageView!.frame.origin.y + notesImageView!.frame.size.height - Common.sharedCommon.calculateDimensionForDevice(20)
            }
            
            let scrollDimWidth = Common.sharedCommon.calculateDimensionForDevice(90)
            let scrollDimHeight = Common.sharedCommon.calculateDimensionForDevice(110)
            
            var frameRect = CGRectMake(xOffset,yOffset,scrollDimWidth,scrollDimHeight)
            
            /* noteTypesScroll = SettingsScroll(frame: frameRect, fillSettings: stickyNotes, contentTypeTitle: "NOTES")
             noteTypesScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
             noteTypesScroll!.scrollView!.delegate = self
             noteTypesScroll!.scrollView!.backgroundColor = UIColor.blackColor()
             noteTypesScroll!.hidden = false
             //self.newNoteView!.addSubview(noteTypesScroll!) */
            
            noteFontsScroll = SettingsScroll(frame: frameRect, fillSettings: kSupportedFonts, contentTypeTitle: "FONTS")
            noteFontsScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
            noteFontsScroll!.scrollView!.delegate = self
            noteFontsScroll!.scrollView!.backgroundColor = UIColor.blackColor()
            noteFontsScroll!.hidden = false
            self.newNoteView!.addSubview(noteFontsScroll!)
            
            
            //xOffset = self.notesImageView!.frame.origin.x + self.notesImageView!.frame.size.width + Common.sharedCommon.calculateDimensionForDevice(10)
            xOffset = UIScreen.mainScreen().bounds.width - scrollDimWidth - noteFontsScroll!.frame.origin.x
            yOffset = self.noteFontsScroll!.frame.origin.y
            frameRect = CGRectMake(xOffset,yOffset,noteFontsScroll!.frame.size.width,noteFontsScroll!.frame.size.height)
            
           /* noteFontColorScroll = SettingsScroll(frame: frameRect, fillSettings: kFontColor, contentTypeTitle:"COLORS")
            noteFontColorScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
            noteFontColorScroll!.scrollView!.delegate = self
            noteFontColorScroll!.hidden = false
            self.newNoteView!.addSubview(noteFontColorScroll!) */
            
            
            noteFontColorScroll = SettingsScroll(frame: frameRect, fillSettings: kFontColor, contentTypeTitle:"COLORS")
            noteFontColorScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
            noteFontColorScroll!.scrollView!.delegate = self
            noteFontColorScroll!.hidden = false
            self.newNoteView!.addSubview(noteFontColorScroll!)
            
            let thumbSize = CGSizeMake(Common.sharedCommon.calculateDimensionForDevice(15),Common.sharedCommon.calculateDimensionForDevice(15))
            
            let redThumbImage = UIImage().imageWithImage(UIImage(named: "redThumb.png")!, scaledToSize: thumbSize)
            redSlider = UISlider(frame: CGRectMake(0,30,noteFontColorScroll!.frame.size.width,20))
            redSlider!.minimumValue = 0.0
            redSlider!.maximumValue = 1.0
            redSlider!.minimumTrackTintColor = UIColor.redColor()
            redSlider!.setThumbImage(redThumbImage, forState: UIControlState.Normal)
            self.noteFontColorScroll!.addSubview(redSlider!)
            redSlider!.addTarget(self, action: #selector(Compose.sliderValueChanged), forControlEvents: UIControlEvents.ValueChanged)
            
            let blueThumbImage = UIImage().imageWithImage(UIImage(named: "blueThumb.png")!, scaledToSize: thumbSize)
            blueSlider = UISlider(frame: CGRectMake(0,redSlider!.frame.origin.y + redSlider!.frame.size.height + 2,noteFontColorScroll!.frame.size.width,20))
            blueSlider!.minimumValue = 0.0
            blueSlider!.maximumValue = 1.0
            blueSlider!.minimumTrackTintColor = UIColor.blueColor()
            blueSlider!.setThumbImage(blueThumbImage, forState: UIControlState.Normal)
            self.noteFontColorScroll!.addSubview(blueSlider!)
            blueSlider!.addTarget(self, action: #selector(Compose.sliderValueChanged), forControlEvents: UIControlEvents.ValueChanged)
            
            let greenThumbImage = UIImage().imageWithImage(UIImage(named: "greenThumb.png")!, scaledToSize: thumbSize)
            greenSlider = UISlider(frame: CGRectMake(0,blueSlider!.frame.origin.y + blueSlider!.frame.size.height + 2,noteFontColorScroll!.frame.size.width,20))
            greenSlider!.minimumValue = 0.0
            greenSlider!.maximumValue = 1.0
            greenSlider!.minimumTrackTintColor = UIColor.greenColor()
            greenSlider!.setThumbImage(greenThumbImage, forState: UIControlState.Normal)
            self.noteFontColorScroll!.addSubview(greenSlider!)
            greenSlider!.addTarget(self, action: #selector(Compose.sliderValueChanged), forControlEvents: UIControlEvents.ValueChanged)
            
            
            
            
            /*  xOffset = self.noteTypesScroll!.frame.origin.x
             yOffset = self.noteTypesScroll!.frame.origin.y + self.noteTypesScroll!.frame.size.height + Common.sharedCommon.calculateDimensionForDevice(15)
             frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
             
             noteFontSizeScroll = SettingsScroll(frame: frameRect, fillSettings: kFontSizes, contentTypeTitle:"SIZE")
             noteFontSizeScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
             noteFontSizeScroll!.scrollView!.delegate = self
             noteFontSizeScroll!.hidden = false
             //self.newNoteView!.addSubview(noteFontSizeScroll!)
             
             
             xOffset = noteFontSizeScroll!.frame.size.width * CGFloat(selectedFontSizeIndex)
             yOffset = noteFontSizeScroll!.scrollView!.frame.origin.y
             noteFontSizeScroll!.scrollView!.scrollRectToVisible(CGRectMake(xOffset, yOffset, noteFontSizeScroll!.scrollView!.frame.size.width,noteFontSizeScroll!.scrollView!.frame.size.height), animated: false)
             
             xOffset = self.noteFontsScroll!.frame.origin.x
             yOffset = self.noteFontSizeScroll!.frame.origin.y
             frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
             
             noteFontColorScroll = SettingsScroll(frame: frameRect, fillSettings: kFontColor, contentTypeTitle:"COLORS")
             noteFontColorScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
             noteFontColorScroll!.scrollView!.delegate = self
             noteFontColorScroll!.hidden = false
             self.newNoteView!.addSubview(noteFontColorScroll!) */
            
            self.assignedTextAttributes()
            self.checkForNoteLock(kPinNotes[0][0])
            
        }
        else if (self.composeNoteType == kComposeNoteTypes.kNoteTypeSponsored) {
            
            
        }
        
    }
    
    
    func composeImageNote() {
        
        
        let width = Common.sharedCommon.calculateDimensionForDevice(290)
        noteDefaultYPos = Common.sharedCommon.calculateDimensionForDevice(50) + (width * 0.5)
        polaroidImageView = UIImageView(frame: CGRectMake(0,0,width,width * 0.90))
        polaroidImageView!.backgroundColor = UIColor.clearColor()
        polaroidImageView!.image = UIImage(named: "nophoto.png")
        polaroidImageView!.center = CGPointMake(UIScreen.mainScreen().bounds.width * 0.5 , noteDefaultYPos!)
        polaroidImageView!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
        self.newNoteView!.addSubview(polaroidImageView!)
        
        let dim = Common.sharedCommon.calculateDimensionForDevice(60)
        
        let cameraImg = UIImageView(frame: CGRectMake(Common.sharedCommon.calculateDimensionForDevice(50),UIScreen.mainScreen().bounds.size.height * 0.75,dim,dim))
        cameraImg.image = UIImage(named: "camera.png")
        //cameraImg.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.25, self.polaroidImageView!.center.y + self.polaroidImageView!.frame.size.height)
        cameraImg.userInteractionEnabled = true
        self.newNoteView!.addSubview(cameraImg)
        let cameratap = UITapGestureRecognizer(target: self, action: #selector(Compose.cameraTapped))
        cameraImg.addGestureRecognizer(cameratap)
        cameraImg.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin)
        
        let photoLibImg = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - (2 *  Common.sharedCommon.calculateDimensionForDevice(50)),cameraImg.frame.origin.y,dim,dim))
        photoLibImg.image = UIImage(named: "photolib.png")
        //photoLibImg.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.75, self.polaroidImageView!.center.y + self.polaroidImageView!.frame.size.height)
        photoLibImg.userInteractionEnabled = true
        self.newNoteView!.addSubview(photoLibImg)
        let photolibtap = UITapGestureRecognizer(target: self, action: #selector(Compose.photolibTapped))
        photoLibImg.addGestureRecognizer(photolibtap)
        photoLibImg.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin)
        
    }
    
    
    func checkForNoteLock(noteName:String) {
        
        if (self.composeNoteType == kComposeNoteTypes.kNoteTypeSponsored) {
            
            if ((Common.sharedCommon.ownerDetails!["sponsorednotes"] as? Array)!.contains(noteName)) {
                
                if (self.noteLock != nil) {
                    
                    self.noteLock!.removeFromSuperview()
                    self.noteLock = nil
                }
            }
            else {
                
                if (self.noteLock == nil) {
                    
                    let noteLockDim = Common.sharedCommon.calculateDimensionForDevice(60.0)
                    self.noteLock = UIImageView(frame: CGRectMake(0,0,noteLockDim,noteLockDim))
                    self.noteLock!.image = UIImage(named: "lock.png")
                    self.noteLock!.userInteractionEnabled = true
                    self.notesImageView!.addSubview(self.noteLock!)
                    
                    let noteLockTap = UITapGestureRecognizer(target: self, action: #selector(Compose.noteLockTapped))
                    self.noteLock?.addGestureRecognizer(noteLockTap)
                    
                }
                
                self.notesImageView!.composeTextView!.resignFirstResponder()
                self.postNote!.alpha = 0.0
                self.pinNote!.alpha = 0.0
                
            }
            
        }
        else {
            
            if (self.noteLock != nil) {
                self.noteLock!.removeFromSuperview()
                self.noteLock = nil
            }
            
        }
    }
    
    
   /* func showPreviewImage() {
     
        if (enteredText == nil ) {
            
            enteredText = ""
        }
        
        self.notesImageView!.image = nil
        let imageFileName = kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex]
        
        let preImg = Common.sharedCommon.textToImage(enteredText!, inImage: UIImage(named: imageFileName)!, atPoint: CGPointMake(0, 0), preferredFont:kSupportedFonts[selectedFontIndex], preferredFontSize: kFontSizes[selectedFontSizeIndex],preferredFontColor: Common.sharedCommon.formColorWithRGB(kFontColor[selectedFontColorIndex]),addExpiry:false,expiryDate:nil)
        
        self.notesImageView!.image = preImg
    } */
    
    
    func assignedTextAttributes() {
        
        //let fontSize = kFontSizes[selectedFontSizeIndex]
        let font = kSupportedFonts[selectedFontIndex]
        //let color = Common.sharedCommon.formColorWithRGB(kFontColor[selectedFontColorIndex])
        let color = Common.sharedCommon.formColorWithRGB([CGFloat(self.redSlider!.value),CGFloat(self.greenSlider!.value),CGFloat(self.blueSlider!.value)])
        
        self.textField!.font = UIFont(name: font, size: self.textFontSize);
        self.textField!.textColor = color
        //maxLinesAllowed = Int(self.notesImageView!.frame.size.height / kFontSizes[selectedFontSizeIndex]) - 1
        //maxLinesAllowed = Int(self.textField!.frame.size.height / kFontSizes[selectedFontSizeIndex]) - 2
        
        let fSize = self.textFontSize
        if ( fSize < 17) {
            
            maxLineForNoteMovement = 4
            maxLinesAllowed = 7
            
        }
        else if (fSize >= 17 && fSize < 26) {
            
            maxLineForNoteMovement = 3
            maxLinesAllowed = 6
        }
        else if (fSize >= 26 && fSize < 45) {
            
            maxLineForNoteMovement = 2
            maxLinesAllowed = 5
        }
        else if (fSize >= 45) {
            
            maxLineForNoteMovement = 1
            maxLinesAllowed = 2
        }
    }
    
    
    func polaroidValidation() -> Bool {
        
        if (composeType == kComposeTypes.kComposePicture) {
            
            if (Common.sharedCommon.config![kKeyPolaroid] == nil) {
                
                return false
            }
        }
        
        return true
    }
    
    
    func checkPinAvailability() {
        
        self.textField?.resignFirstResponder()
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        activity?.startAnimating()
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetPins , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.activity?.stopAnimating()
                
            })
            
            if (result == true) {
                
                let err:String? = response.objectForKey("data")?.objectForKey("error") as? String
                
                if (err == nil) {
                    
                    let data = response.objectForKey("data") as? Dictionary<String,AnyObject>
                    if (data!.count == 0) {
                        
                        self.showNoPins()
                    }
                    else {
                
                        let keys = Array(data!.keys)
                        var totalPinCount = 0
                        
                        for idx in 0 ..< keys.count {
                        
                            let type = keys[idx] as String
                            let count = String(data![type]!)
                            
                            totalPinCount = totalPinCount + Int(count)!
                        
                        }
                        
                        if (totalPinCount == 0) {
                            
                            self.showNoPins()
                            
                        }else {
                            
                            //self.showPins(data!)
                            let pinPoint = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, self.composeTypeImageView!.center.y + Common.sharedCommon.calculateDimensionForDevice(30))
                            Common.sharedCommon.showPins(data!, attachView: self.newNoteView!, attachPosition: pinPoint,delegate:self)
                        }
                    }
                    
                }
                else {
                    
                    print(err)
                }
                
            }
            else {
                
                print(response["data"])
                
            }
        }
    }
    
    func showNoPins() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            /*self.notesImageView?.alpha = 0.0
            self.polaroidImageView?.alpha = 0.0
            self.noteTypesScroll?.alpha = 0.0
            self.noteFontsScroll?.alpha = 0.0
            self.noteFontSizeScroll?.alpha = 0.0
            self.noteFontColorScroll?.alpha = 0.0 */
            
           /* if (self.pinBuyView == nil) {
                
                self.pinBuyView = PinBuy(frame: CGRectMake(0,self.notesImageView!.frame.origin.y,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - self.notesImageView!.frame.origin.y),overrideTextColor:nil)
                self.pinBuyView!.pinBuyDelegate = self
                self.newNoteView!.addSubview(self.pinBuyView!)
            } */
            
            if (self.paymentController == nil) {
                
                let yPos:CGFloat = 0
                let frame = CGRectMake(0,yPos,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos)
                self.paymentController  = PaymentController(frame:frame, overrideTextColor:nil,module: kPaymentModulePIN)
                self.addChildViewController(self.paymentController!)
                self.newNoteView!.addSubview(self.paymentController!.view)
                self.paymentController!.didMoveToParentViewController(self)
                
                self.paymentController!.pinView!.pinBuyDelegate = self
            }
        }
    }
    
  /*  func showPins(data:Dictionary<String,AnyObject>) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            if (self.pinPostView == nil) {
            
                let width = Common.sharedCommon.calculateDimensionForDevice(70)
                let height = Common.sharedCommon.calculateDimensionForDevice(30)
            
                self.pinPostView = UIView(frame: CGRectMake(0,0,width * CGFloat(data.count) ,height))
                self.pinPostView!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, self.composeTypeImageView!.center.y + height)
                self.pinPostView!.backgroundColor = UIColor.clearColor()
                self.newNoteView!.addSubview(self.pinPostView!)
                
                var percent:CGFloat = 0.25
                var xPos:CGFloat = self.pinPostView!.frame.size.width * percent
                let yPos:CGFloat = height * 0.5
                
                var keys = Array(data.keys)
                
                for idx in 0 ..< keys.count {
                    
                    let type = keys[idx] as String
                    let count = String(data[type]!)
            
                    
                    let pinType = PinButton(frame:CGRectMake(0,0,height,height),type:type,PinCount:count)
                    pinType.pinButtonDelegate = self
                    pinType.center = CGPointMake(xPos,yPos)
                    self.pinPostView!.addSubview(pinType)
                    
                    percent = percent + 0.25
                    xPos = self.pinPostView!.frame.size.width * percent
                }
            }
            
        }
        
    } */
    
    
    func noteTapped(sender:UITapGestureRecognizer) {
        
       /* if (self.pinBuyView != nil) {
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                
                self.pinBuyView!.removeFromSuperview()
                self.pinBuyView = nil
                
                
                self.notesImageView?.alpha = 1.0
                self.polaroidImageView?.alpha = 1.0
                self.noteTypesScroll?.alpha = 1.0
                self.noteFontsScroll?.alpha = 1.0
                self.noteFontSizeScroll?.alpha = 1.0
                self.noteFontColorScroll?.alpha = 1.0
                
            }
            
            
        }
        else {
            
            self.postTapped(sender)
        } */
        
        self.postTapped(sender)
    }
    
    
    func postTapped(sender:UITapGestureRecognizer) {
        
        var characterCount:Int?
        
        if (textField != nil) {
            
            characterCount = textField!.text!.characters.count
        }
        else {
            
            characterCount = enteredText!.characters.count
            
        }
        
        
        if (characterCount >= kMinRequiredCharacters && polaroidValidation()) {
            
            
            if (textField != nil) {
                
                enteredText = textField!.text!
                textField!.resignFirstResponder()
                textField!.removeFromSuperview()
                textField = nil
            }
            
            if (notesImageView != nil) {
            
                notesImageView!.removeFromSuperview()
                notesImageView = nil
            }
            
            if (newNoteView != nil) {
            
                newNoteView!.removeFromSuperview()
                newNoteView = nil
            }
            
            if (composeDelegate != nil) {
                
                var composeProperty = "N"
                var imgFileName = ""
                
                
                if (composeType == kComposeTypes.kComposePicture) {
                    
                    composeProperty = "P"
                    
                    let ownerID = Common.sharedCommon.config!["ownerId"] as! String
                    let date = NSDateFormatter()
                    
                    date.dateFormat = "ddMMyyyyhhmmss"
                    imgFileName = "Pol_" + ownerID + "_" + date.stringFromDate(NSDate()) + ".jpg"
                    
                }
                
                var isPinned = false
                var pinType = ""
                
                if (sender.view!.tag == 2) {
                    
                    isPinned = true
                    pinType = (sender.view! as! UILabel).text!
                }
                
                //noteFontColor: kFontColor[selectedFontColorIndex]
                let color = [CGFloat(self.redSlider!.value),CGFloat(self.greenSlider!.value),CGFloat(self.blueSlider!.value)]
                self.composeDelegate!.postAWallNote(kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex] as String, noteText: enteredText!, noteFont: kSupportedFonts[selectedFontIndex], noteFontSize: textFontSize , noteFontColor: color,noteProperty:composeProperty,imageurl: imgFileName, isPinned:isPinned,pinType:pinType)
                
            }
            
            self.dismissViewControllerAnimated(true) { () -> Void in
            
                
            }
            
        }
        else {
            
            print("Need atleast 20 charatcers")
        }
        
    }
    
    
    func noteSwiped() {
        
        let animateImgView = UIImageView(frame: self.notesImageView!.frame)
        //animateImgView.image = UIImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        animateImgView.image = UIImage().noteImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        self.view.addSubview(animateImgView)
        
        selectedNoteInNoteIndex = selectedNoteInNoteIndex + 1
        let notes = kPinNotes[selectedNoteIndex]
        
        if (selectedNoteInNoteIndex >= notes.count) {
            
            selectedNoteInNoteIndex = 0
        }
        
        //self.notesImageView!.image = UIImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        self.notesImageView!.image = UIImage().noteImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        self.checkForNoteLock(kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
                animateImgView.center = CGPointMake(animateImgView.center.x, animateImgView.center.y + kScreenHeight)
            
            }) { (Bool) -> Void in
                
                animateImgView.removeFromSuperview()
                
        }
        
       
    }
    
    func changeCompseMode() {
        
        //self.viewDidLoad()
        
        if (self.composeType == kComposeTypes.kComposeNote) {
            
            self.composeType = kComposeTypes.kComposePicture
        }
        else if (self.composeType == kComposeTypes.kComposePicture) {
            
            self.composeType = kComposeTypes.kComposeNote
        }
        
        if (newNoteView != nil) {
            
            newNoteView!.removeFromSuperview()
            newNoteView = nil
            self.composeTypeImageView = nil
            self.noteTypeImageView = nil
            
            self.addNewNoteView(self.composeType)
        }
    }
    
    
    func changeNoteTypeMode() {
        
        if (self.composeNoteType == kComposeNoteTypes.kNoteTypeFree) {
            
            self.composeNoteType = kComposeNoteTypes.kNoteTypeSponsored
            kPinNotes = kSponsoredPinNotes
        }
        else if (self.composeNoteType == kComposeNoteTypes.kNoteTypeSponsored) {
            
            self.composeNoteType = kComposeNoteTypes.kNoteTypeFree
            kPinNotes = kFreePinNotes
        }
        
        if (newNoteView != nil) {
            
            newNoteView!.removeFromSuperview()
            newNoteView = nil
            self.composeTypeImageView = nil
            self.noteTypeImageView = nil
            
            self.addNewNoteView(self.composeType)
        }
    }
    
    
    func sliderValueChanged() {
        
        self.assignedTextAttributes()
    }
    
    
    func cameraTapped() {
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true ) {
            
            self.imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(imgPicker, animated: true, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    func photolibTapped() {
        
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == true ) {
            
            self.imgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(imgPicker, animated: true, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    
    func noteLockTapped() {
        
        
        if (self.paymentController != nil) {
            
            self.paymentController!.view.removeFromSuperview()
            self.paymentController = nil
        }
        
        let yPos:CGFloat = 0
        let frame = CGRectMake(0,yPos,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height - yPos)
        
        self.paymentController  = PaymentController(frame:frame, overrideTextColor:nil,module: kPaymentModuleNote)
        self.addChildViewController(self.paymentController!)
        self.newNoteView!.addSubview(self.paymentController!.view)
        self.paymentController!.didMoveToParentViewController(self)
    }
    
    
}
