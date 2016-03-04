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
    
    func postAWallNote(noteType:String?,noteText:String?,noteFont:String?,noteFontSize:CGFloat?,noteFontColor:Array<CGFloat>,noteProperty:String?,imageurl:String?,isPinned:Bool)
}


class Compose:UIViewController,UITextViewDelegate,UIScrollViewDelegate,ComposeNoteDelegate,CloseViewProtocolDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
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
    var composeTypeImageView:UIImageView?
    var imgPicker:UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        
        for noteTypes in kPinNotes {
            
            stickyNotes.append(noteTypes[0])
        }
        
        self.addNewNoteView(composeType)
        
        currentLine = maxLineForNoteMovement - 1
        
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        
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
        
        if (self.composeType == kComposeTypes.kComposePicture) {
            
            return UIInterfaceOrientationMask.Portrait
        }
        
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
        
        if (scrollView == noteTypesScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteTypesScroll!.scrollView!.contentOffset.x
            selectedNoteIndex = Int(contentOffset / self.noteTypesScroll!.scrollView!.frame.size.width)
            self.notesImageView!.image = UIImage(named: stickyNotes[selectedNoteIndex])
            
        }
        
        if (scrollView == noteFontsScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontsScroll!.scrollView!.contentOffset.x
            selectedFontIndex = Int(contentOffset / self.noteFontsScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
        }
        
        if (scrollView == noteFontSizeScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontSizeScroll!.scrollView!.contentOffset.x
            selectedFontSizeIndex = Int(contentOffset / self.noteFontSizeScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
            
        }
        
        if (scrollView == noteFontColorScroll!.scrollView!) {
            
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
        let tap = UITapGestureRecognizer(target: self, action: "dimissKeyboard")
        bgImage.addGestureRecognizer(tap)
        
        
        let composeDim = Common.sharedCommon.calculateDimensionForDevice(35)
        
        if (self.composeTypeImageView == nil) {
            
            
            self.composeTypeImageView = UIImageView(frame: CGRectMake(0,0,composeDim,composeDim))
            self.composeTypeImageView!.userInteractionEnabled = true
            self.view.addSubview(self.composeTypeImageView!)
            
            let composeTap = UITapGestureRecognizer(target: self, action: "changeCompseMode")
            self.composeTypeImageView!.addGestureRecognizer(composeTap)
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
        let postNote  = UIImageView(frame: CGRectMake(xOffset, 0, composeDim, composeDim))
        postNote.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(.FlexibleBottomMargin)
        postNote.image = UIImage(named: "noteBlue1.png")
        postNote.userInteractionEnabled = true
        postNote.tag = 1
        let postTap = UITapGestureRecognizer(target: self, action: "postTapped:")
        postNote.addGestureRecognizer(postTap)
        self.newNoteView!.addSubview(postNote)
        
        
        let pinNote  = UIImageView(frame: CGRectMake(xOffset + (1.5 * composeDim), 0, composeDim, composeDim))
        pinNote.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(.FlexibleBottomMargin)
        pinNote.image = UIImage(named: "pin.png")
        pinNote.userInteractionEnabled = true
        pinNote.tag = 2
        let pinTap = UITapGestureRecognizer(target: self, action: "postTapped:")
        pinNote.addGestureRecognizer(pinTap)
        self.newNoteView!.addSubview(pinNote)
        
        
        
        let closeImage = CloseView(frame: CGRectMake(UIScreen.mainScreen().bounds.width - composeDim, 0, composeDim, composeDim))
        closeImage.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleBottomMargin)
        closeImage.closeViewDelegate = self
        self.newNoteView!.addSubview(closeImage)
        
        if (cType == kComposeTypes.kComposeNote) {
            
            self.composeTypeImageView!.image = UIImage(named: "camera.png")
            self.composeNewNote()
        }
        else if (cType == kComposeTypes.kComposePicture){
            
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
            self.composeTypeImageView!.image = UIImage(named: "notes.png")
            self.composeImageNote()
        }
        
        
        
    }
    
    func composeNewNote() {
        
        
        for font in kFontSizes {
            
            if (font == 30.0) {
                
                selectedFontSizeIndex = kFontSizes.indexOf(font)!
            }
        }
        
        
        
        let width = Common.sharedCommon.calculateDimensionForDevice(290)
        noteDefaultYPos = Common.sharedCommon.calculateDimensionForDevice(30) + (width * 0.5)
        let noteFrame = CGRectMake(0,0,width,width * 0.90)
        notesImageView = ComposeNote(frame: noteFrame, withImage: stickyNotes[0], withFontIndex:selectedFontSizeIndex)
        notesImageView!.center = CGPointMake(UIScreen.mainScreen().bounds.width * 0.5 , noteDefaultYPos!)
        notesImageView!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin)
        notesImageView!.composeNoteDelegate = self
        orgNotePosition = notesImageView!.frame
        orgNoteCenter = notesImageView!.center
        centerOffset = self.orgNoteCenter!.y
        textField = notesImageView!.composeTextView
        textField!.delegate = self
        self.newNoteView!.addSubview(notesImageView!)
        
        
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
        
        noteTypesScroll = SettingsScroll(frame: frameRect, fillSettings: stickyNotes, contentTypeTitle: "NOTES")
        noteTypesScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        noteTypesScroll!.scrollView!.delegate = self
        noteTypesScroll!.scrollView!.backgroundColor = UIColor.blackColor()
        noteTypesScroll!.hidden = false
        self.newNoteView!.addSubview(noteTypesScroll!)
       
        
        //xOffset = self.notesImageView!.frame.origin.x + self.notesImageView!.frame.size.width + Common.sharedCommon.calculateDimensionForDevice(10)
        xOffset = UIScreen.mainScreen().bounds.width - scrollDimWidth - noteTypesScroll!.frame.origin.x
        yOffset = self.noteTypesScroll!.frame.origin.y
        frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
        
        noteFontsScroll = SettingsScroll(frame: frameRect, fillSettings: kSupportedFonts, contentTypeTitle:"FONTS")
        noteFontsScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        noteFontsScroll!.scrollView!.delegate = self
        noteFontsScroll!.hidden = false
        self.newNoteView!.addSubview(noteFontsScroll!)
        
        
        xOffset = self.noteTypesScroll!.frame.origin.x
        yOffset = self.noteTypesScroll!.frame.origin.y + self.noteTypesScroll!.frame.size.height + Common.sharedCommon.calculateDimensionForDevice(15)
        frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
        
        noteFontSizeScroll = SettingsScroll(frame: frameRect, fillSettings: kFontSizes, contentTypeTitle:"SIZE")
        noteFontSizeScroll!.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        noteFontSizeScroll!.scrollView!.delegate = self
        noteFontSizeScroll!.hidden = false
        self.newNoteView!.addSubview(noteFontSizeScroll!)
        
        
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
        self.newNoteView!.addSubview(noteFontColorScroll!)
        
        self.assignedTextAttributes()
        
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
        
        let cameraImg = UIImageView(frame: CGRectMake(0,0,dim,dim))
        cameraImg.image = UIImage(named: "camera.png")
        cameraImg.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.25, self.polaroidImageView!.center.y + self.polaroidImageView!.frame.size.height)
        cameraImg.userInteractionEnabled = true
        self.newNoteView!.addSubview(cameraImg)
        let cameratap = UITapGestureRecognizer(target: self, action: "cameraTapped")
        cameraImg.addGestureRecognizer(cameratap)
        
        let photoLibImg = UIImageView(frame: CGRectMake(0,0,dim,dim))
        photoLibImg.image = UIImage(named: "photolib.png")
        photoLibImg.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.75, self.polaroidImageView!.center.y + self.polaroidImageView!.frame.size.height)
        photoLibImg.userInteractionEnabled = true
        self.newNoteView!.addSubview(photoLibImg)
        let photolibtap = UITapGestureRecognizer(target: self, action: "photolibTapped")
        photoLibImg.addGestureRecognizer(photolibtap)
        
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
        
        let fontSize = kFontSizes[selectedFontSizeIndex]
        let font = kSupportedFonts[selectedFontIndex]
        let color = Common.sharedCommon.formColorWithRGB(kFontColor[selectedFontColorIndex])
        
        self.textField!.font = UIFont(name: font, size: fontSize);
        self.textField!.textColor = color
        //maxLinesAllowed = Int(self.notesImageView!.frame.size.height / kFontSizes[selectedFontSizeIndex]) - 1
        //maxLinesAllowed = Int(self.textField!.frame.size.height / kFontSizes[selectedFontSizeIndex]) - 2
        
        let fSize = kFontSizes[selectedFontSizeIndex]
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
                
                if (sender.view!.tag == 2) {
                    
                    isPinned = true
                }
                    
                self.composeDelegate!.postAWallNote(kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex] as String, noteText: enteredText!, noteFont: kSupportedFonts[selectedFontIndex], noteFontSize: kFontSizes[selectedFontSizeIndex], noteFontColor: kFontColor[selectedFontColorIndex],noteProperty:composeProperty,imageurl: imgFileName, isPinned:isPinned)
                
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
        animateImgView.image = UIImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        self.view.addSubview(animateImgView)
        
        selectedNoteInNoteIndex = selectedNoteInNoteIndex + 1
        let notes = kPinNotes[selectedNoteIndex]
        
        if (selectedNoteInNoteIndex >= notes.count) {
            
            selectedNoteInNoteIndex = 0
        }
        
        self.notesImageView!.image = UIImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        
        
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
            
            self.addNewNoteView(self.composeType)
        }
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
    
    
    
}
